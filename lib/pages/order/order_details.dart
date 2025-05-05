import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spl_front/pages/order/orders_list.dart';

import '../../../models/order_models/order_model.dart';
import '../../../spl/spl_variables.dart';
import '../../../utils/ui/format_currency.dart';
import '../../../widgets/helpers/custom_loading.dart';
import '../../bloc/orders_bloc/order_bloc.dart';
import '../../bloc/orders_bloc/order_event.dart';
import '../../models/helpers/intern_logic/user_type.dart';
import '../../models/users_models/user.dart';
import '../../services/api_services/order_service/order_service.dart';
import '../../services/api_services/user_service/user_service.dart';
import '../../utils/strings/payment_strings.dart';
import '../../utils/ui/order_statuses.dart';
import '../../widgets/logic_widgets/order_widgets/orders/list/products_popup.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/modify_order_status_options.dart';
import '../../widgets/logic_widgets/order_widgets/orders/tracking/shipping_company_selection.dart';
import '../../widgets/style_widgets/navigation_bars/nav_bar.dart';

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

  @override
  void initState() {
    super.initState();
    // Fetch customer and domiciliary data
    _customerFuture = UserService.getUser(widget.order.idUser!);
    _domiciliaryFuture = widget.order.idDomiciliary?.isNotEmpty == true
        ? UserService.getUser(widget.order.idDomiciliary!)
        : null;
    selectedShippingCompany =
        widget.order.transportCompany ?? 'Sin seleccionar';
    _loadOrder();
  }

  /// Load order details from service
  void _loadOrder() {
    _orderFuture = OrderService.getOrderById(widget.order.id!).then((res) {
      final (fresh, err) = res;
      if (err != null || fresh == null) {
        throw Exception(err ?? 'Order not found');
      }
      return fresh;
    });
  }

  /// Calculate next order status in flow
  int _idx(String s) => ['confirmed', 'preparing', 'on-the-way', 'delivered']
      .indexOf(normalizeOnTheWay(s));

  String _computeNextStatus(OrderModel order) {
    final rawLast = order.orderStatuses.isNotEmpty
        ? normalizeOnTheWay(order.orderStatuses.last.status)
        : 'confirmed';
    final lastIdx = _idx(rawLast);
    return lastIdx + 1 < 4
        ? ['confirmed', 'preparing', 'on-the-way', 'delivered'][lastIdx + 1]
        : rawLast;
  }

  /// Show forbidden on the way business/admin
  void _onTheWayBusinessAdminError() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  'Contacta a un domiciliario de tu empresa para que realice el envío hacía el cliente.',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text(
                  PaymentStrings.accept,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: CustomBottomNavigationBar(
        userType: widget.userType,
        context: context,
      ),
      body: FutureBuilder<OrderModel>(
        future: _orderFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            // Wait to load order
            return const SizedBox.shrink();
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error al cargar la orden:\nContacta a soporte',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final order = snap.data!;
          final nextStatus = _computeNextStatus(order);
          final lastStatus = order.orderStatuses.isNotEmpty
              ? normalizeOnTheWay(order.orderStatuses.last.status)
              : 'confirmed';
          final shippedOrAfter = _idx(lastStatus) >= _idx('on-the-way');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!kIsWeb) _buildHeader(),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                              return const SizedBox.shrink();
                            }
                            return Text(
                                su.data?.fullname ?? 'Usuario No Disponible');
                          },
                        ),
                        const SizedBox(height: 16),

                        // Shipping / delivery section
                        if (SPLVariables.hasRealTimeTracking) ...[
                          _sectionTitle('Reparto'),
                          FutureBuilder<UserModel?>(
                            future: _domiciliaryFuture,
                            builder: (_, sd) {
                              if (_domiciliaryFuture != null &&
                                  sd.connectionState ==
                                      ConnectionState.waiting) {
                                return const CustomLoading();
                              }
                              return Text(
                                sd.data?.fullname ?? 'Domiciliario No asignado',
                              );
                            },
                          ),
                        ] else ...[
                          _subTitle('Compañía de Envío'),
                          if (widget.userType == UserType.customer)
                            Text(
                              order.transportCompany ?? 'Sin asignar',
                            )
                          else if (widget.userType == UserType.business ||
                              widget.userType == UserType.admin)
                            shippedOrAfter
                                ? Text(selectedShippingCompany)
                                : InkWell(
                                    onTap: () => _showShippingPopup(),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedShippingCompany,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                      ],
                                    ),
                                  ),
                        ],

                        const SizedBox(height: 16),

                        // Pending debt payment for cash orders
                        if (widget.userType == UserType.customer &&
                            order.debt! > 0) ...[
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2),
                          Text(
                            'Tu pendiente de pago en efectivo es de:',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatCurrency(order.debt!),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Change status for business/admin
              if ((widget.userType == UserType.business ||
                      widget.userType == UserType.admin) &&
                  widget.order.orderStatuses.last.status != 'delivered')
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Cambiar estado',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showStatusDialog(order, nextStatus),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .05,
          left: 10,
          right: 10,
        ),
        height: 80,
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      );

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
      );

  Widget _subTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
      );

  Widget _buildStaticInfo(OrderModel order) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Número de Orden', '${order.id}'),
          _infoRow(
            'Fecha',
            DateFormat('dd/MM/yyyy').format(order.creationDate!),
          ),
          _infoRow(
            'Productos',
            '${order.orderProducts.fold<int>(0, (sum, p) => sum + p.quantity)} ítems',
            onTap: () => showDialog(
              context: context,
              builder: (_) => ProductPopup(orderModel: order),
            ),
            withArrow: true,
          ),
          _infoRow('Total', formatCurrency(order.total!)),
        ],
      );

  Widget _infoRow(
    String label,
    String value, {
    VoidCallback? onTap,
    bool withArrow = false,
  }) =>
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
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              if (withArrow) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );

  void _showShippingPopup() => showDialog(
        context: context,
        builder: (_) => ShippingCompanyPopup(
          selectedCompany: selectedShippingCompany,
          onCompanySelected: (c) {
            setState(() => selectedShippingCompany = c);
          },
        ),
      );

  void _showStatusDialog(OrderModel order, String nextStatus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkBlue, width: 1.5),
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
          height: MediaQuery.of(context).size.height * 0.35,
          child: ModifyOrderStatusOptions(
              selectedStatus: nextStatus, order: widget.order),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: darkBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: darkBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              switch (nextStatus) {
                case 'preparing':
                  context.read<OrdersBloc>().add(PrepareOrderEvent(order.id!));
                  break;
                case 'on-the-way':
                  SPLVariables.hasRealTimeTracking
                      ? _onTheWayBusinessAdminError()
                      : _confirmOnTheWay(order);
                  return;
                case 'delivered':
                  context
                      .read<OrdersBloc>()
                      .add(DeliveredOrderEvent(order.id!));
                  break;
              }
              Navigator.pop(context);
              setState(_loadOrder);
              showSuccessDialogStatuses.call(context, widget.userType);
            },
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmOnTheWay(OrderModel order) {
    if (selectedShippingCompany == 'Sin seleccionar') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Seleccione una compañía de envío.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final guide = '$selectedShippingCompany-${order.id}';
      context.read<OrdersBloc>().add(
            OnTheWayTransportOrderEvent(
              orderId: order.id!,
              transportCompany: selectedShippingCompany,
              shippingGuide: guide,
            ),
          );
      Navigator.pop(context);
      setState(_loadOrder);
      showSuccessDialogStatuses.call(context, widget.userType);
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
