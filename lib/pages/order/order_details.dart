import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../models/logic/user_type.dart';
import '../../../models/order_models/order_model.dart';
import '../../../models/user.dart';
import '../../../services/api/order_service.dart';
import '../../../services/api/user_service.dart';
import '../../../spl/spl_variables.dart';
import '../../../utils/ui/order_statuses.dart'; // normalizeOnTheWay
import '../../../widgets/navigation_bars/nav_bar.dart';
import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_event.dart';
import '../../utils/ui/format_currency.dart';
import '../../widgets/order/list/products_popup.dart';
import '../../widgets/order/tracking/modify_order_status_options.dart';
import '../../widgets/order/tracking/shipping_company_selection.dart';
import 'orders_list.dart';

class OrderDetailsScreen extends StatelessWidget {
  final UserType userType;
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.userType,
    required this.order,
  });

  @override
  Widget build(BuildContext context) =>
      OrderDetailsPage(userType: userType, order: order);
}

class OrderDetailsPage extends StatefulWidget {
  final UserType userType;
  final OrderModel order;
  final Color backgroundColor;

  const OrderDetailsPage({
    super.key,
    required this.userType,
    required this.order,
    this.backgroundColor = Colors.white,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  static const Color darkBlue = Color(0xFF0D47A1);

  late Future<OrderModel> _orderFuture;
  late final Future<UserModel?> _customerFuture;
  late final Future<UserModel?>? _domiciliaryFuture;
  late String selectedShippingCompany;

  static const List<String> _flow = [
    'confirmed',
    'preparing',
    'on-the-way',
    'delivered',
  ];

  int _idx(String s) => _flow.indexOf(s);

  @override
  void initState() {
    super.initState();
    _customerFuture = UserService.getUser(widget.order.idUser!);
    _domiciliaryFuture = widget.order.idDomiciliary?.isNotEmpty == true
        ? UserService.getUser(widget.order.idDomiciliary!)
        : null;
    _loadOrder();
    selectedShippingCompany =
        widget.order.transportCompany ?? 'Sin seleccionar';
  }

  void _loadOrder() {
    _orderFuture = OrderService.getOrderById(widget.order.id!).then((res) {
      final (fresh, err) = res;
      if (err != null || fresh == null) {
        throw Exception(err ?? 'Order not found');
      }
      return fresh;
    });
  }

  String _computeNextStatus(OrderModel order) {
    final rawLast = order.orderStatuses.isNotEmpty
        ? normalizeOnTheWay(order.orderStatuses.last.status)
        : 'confirmed';
    final lastIdx = _flow.indexOf(rawLast);
    return (lastIdx + 1 < _flow.length) ? _flow[lastIdx + 1] : rawLast;
  }

  /* ----------  UI helpers ---------- */
  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: darkBlue)),
      );

  Widget _subTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: darkBlue)),
      );

  Widget infoRow(String label, String value,
          {VoidCallback? onTap, bool withArrow = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 4),
                    Text(value,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black)),
                  ],
                ),
              ),
              if (withArrow)
                const Icon(Icons.chevron_right, color: Colors.black)
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: CustomBottomNavigationBar(
          userType: widget.userType, context: context),
      body: FutureBuilder<OrderModel>(
        future: _orderFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error cargando orden'));
          }

          final order = snap.data!;
          final nextStatus = _computeNextStatus(order);

          /* --- estado actual normalizado --- */
          final lastStatus = order.orderStatuses.isNotEmpty
              ? normalizeOnTheWay(order.orderStatuses.last.status)
              : 'confirmed';
          final bool shippedOrAfter = _idx(lastStatus) >= _idx('on-the-way');

          /* --- refresca company local por si cambió --- */
          selectedShippingCompany =
              order.transportCompany ?? selectedShippingCompany;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!kIsWeb) _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Detalles de la Orden'),
                      _buildStaticInfo(order),
                      const SizedBox(height: 12),
                      _sectionTitle('Cliente'),
                      FutureBuilder<UserModel?>(
                        future: _customerFuture,
                        builder: (_, su) {
                          if (su.connectionState == ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return Text(su.data?.fullname ?? '---',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black));
                        },
                      ),
                      const SizedBox(height: 16),

                      /* -------- reparto / compañía -------- */
                      if (SPLVariables.hasRealTimeTracking) ...[
                        _sectionTitle('Reparto'),
                        FutureBuilder<UserModel?>(
                          future: _domiciliaryFuture,
                          builder: (_, sd) {
                            if (_domiciliaryFuture != null &&
                                sd.connectionState == ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return Text(
                                sd.data?.fullname ?? 'Domiciliario No asignado',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black));
                          },
                        ),
                      ] else ...[
                        _subTitle('Compañía de Envío'),
                        if (widget.userType == UserType.customer)
                          Text(
                            order.transportCompany ?? 'Sin asignar',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          )
                        else if (widget.userType == UserType.business ||
                            widget.userType == UserType.admin)
                          shippedOrAfter
                              ? Text(
                                  selectedShippingCompany,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                )
                              : InkWell(
                                  onTap: () => _showShippingPopup(context),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selectedShippingCompany,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down,
                                          color: Colors.black),
                                    ],
                                  ),
                                ),
                      ],
                    ],
                  ),
                ),
              ),

              /* ------- botón Cambiar estado ------- */
              if (widget.userType == UserType.business ||
                  widget.userType == UserType.admin)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Cambiar estado',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () =>
                          _showStatusDialog(context, order, nextStatus),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /* ---------- header, static info, popups … (sin cambios) ---------- */
  Widget _buildHeader(BuildContext ctx) => Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(ctx).size.height * .05, left: 10, right: 10),
        height: 80,
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(ctx),
        ),
      );

  Widget _buildStaticInfo(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        infoRow('Número de Orden', '${order.id}'),
        infoRow(
          'Fecha',
          DateFormat('dd/MM/yyyy').format(order.creationDate!),
        ),
        infoRow(
          'Productos',
          '${order.orderProducts.fold<int>(0, (sum, p) => sum + p.quantity)} ítems',
          onTap: () => _showProductPopup(context, order),
          withArrow: true,
        ),
        infoRow('Total', formatCurrency(order.total!)),
      ],
    );
  }

  void _showProductPopup(BuildContext ctx, OrderModel order) =>
      showDialog(context: ctx, builder: (_) => ProductPopup(orderModel: order));

  void _showShippingPopup(BuildContext ctx) => showDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (_) => ShippingCompanyPopup(
          selectedCompany: selectedShippingCompany,
          onCompanySelected: (c) => setState(() => selectedShippingCompany = c),
        ),
      );

  void _showStatusDialog(
      BuildContext ctx, OrderModel order, String nextStatus) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBlue, width: 1.5),
        ),
        title: const Text(
          'Cambiar estado',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.35,
          child: ModifyOrderStatusOptions(selectedStatus: nextStatus),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: darkBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: darkBlue, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlue,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              switch (nextStatus) {
                case 'preparing':
                  ctx.read<OrdersBloc>().add(PrepareOrderEvent(order.id!));
                  break;
                case 'on-the-way':
                  handleConfirmShippingCompany(ctx, selectedShippingCompany);
                  return;
                case 'delivered':
                  ctx.read<OrdersBloc>().add(DeliveredOrderEvent(order.id!));
                  break;
              }
              Navigator.pop(ctx);
              setState(() => _loadOrder());
              showSuccessDialogStatuses.call(ctx, widget.userType);
            },
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void handleConfirmShippingCompany(BuildContext ctx, String company) {
    if (company == 'Sin seleccionar') {
      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: darkBlue, width: 1.5),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Por favor, seleccione una compañía de envío.',
            style: TextStyle(fontSize: 16),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: darkBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: darkBlue, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    } else {
      final guide = '$company-${widget.order.id}';
      ctx.read<OrdersBloc>().add(
            OnTheWayTransportOrderEvent(
              orderId: widget.order.id!,
              transportCompany: company,
              shippingGuide: guide,
            ),
          );
      Navigator.pop(ctx); // cierra el dialog de estado
      setState(() => _loadOrder());
      showSuccessDialogStatuses.call(ctx, widget.userType);
    }
  }

  void showSuccessDialogStatuses(BuildContext ctx, UserType userType) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBlue, width: 1.5),
        ),
        title: const Icon(Icons.check_circle, size: 48, color: darkBlue),
        content: const Text(
          'Estado actualizado correctamente',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlue,
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => OrdersPage(userType: userType),
                ),
                ModalRoute.withName('/'),
              );
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
