// lib/widgets/order/tracking/order_action_buttons.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/order_models/order_model.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_event.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../models/logic/user_type.dart';
import '../../../pages/order/order_details.dart';
import '../../../pages/order/orders_list.dart';
import '../../../utils/strings/order_strings.dart';
import '../../../utils/ui/order_statuses.dart';
import '../../order/tracking/shipping_company_selection.dart';

class OrderActionButtons extends StatelessWidget {
  /* ───────── colores corporativos ───────── */
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFF258BD9);

  final String selectedStatus;
  final bool showDetailsButton;
  final bool showConfirmButton;
  final UserType userType;
  final OrderModel? order;

  const OrderActionButtons({
    super.key,
    required this.selectedStatus,
    this.showDetailsButton = true,
    this.showConfirmButton = true,
    required this.userType,
    this.order,
  });

  /* flujo normalizado */
  static const List<String> _flow = [
    'confirmed',
    'preparing',
    'on-the-way',
    'delivered',
  ];
  int _idx(String s) => _flow.indexOf(normalizeOnTheWay(s));

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    /* sincronizar con estado del bloc */
    final blocState = context.watch<OrdersBloc>().state;
    OrderModel current = order!;
    if (blocState is OrdersLoaded) {
      final upd =
          blocState.allOrders.firstWhereOrNull((o) => o.id == order!.id);
      if (upd != null) current = upd;
    }

    final curIdx = _idx(current.orderStatuses.last.status);
    final selIdx = _idx(selectedStatus);
    final canConfirm = selIdx == curIdx + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          /* 1 · Confirmar / Cambiar estado */
          if (showConfirmButton)
            _plainConfirmButton(canConfirm, context, current),
          if (showConfirmButton && showDetailsButton)
            const SizedBox(height: 16),

          /* 2 · Detalles de la orden */
          if (showDetailsButton) _prettyDetailsButton(context, current),
        ],
      ),
    );
  }

  /* BOTÓN “CONFIRMAR” (mantiene estilo sencillo) */
  Widget _plainConfirmButton(bool canConfirm, BuildContext ctx, OrderModel o) {
    return ElevatedButton(
      onPressed: canConfirm ? () => _confirm(ctx, o) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canConfirm ? darkBlue : Colors.grey.shade400,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(
        'Confirmar Cambio de Estado',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  /* BOTÓN “DETALLES” ESTILIZADO */
  Widget _prettyDetailsButton(BuildContext ctx, OrderModel o) {
    return GestureDetector(
      onTap: () => _goToDetails(ctx, o),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBlue, darkBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              OrderStrings.orderDetailsTitle,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /* Navegar a detalles */
  void _goToDetails(BuildContext ctx, OrderModel o) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(userType: userType, order: o),
      ),
    );
  }

  /* Confirmar cambio de estado */
  void _confirm(BuildContext ctx, OrderModel o) {
    switch (selectedStatus) {
      case 'preparing':
        ctx.read<OrdersBloc>().add(PrepareOrderEvent(o.id!));
        _showSnack(ctx);
        _goBackToOrders(ctx);
        break;
      case 'on-the-way':
        showDialog(
          context: ctx,
          barrierDismissible: true,
          builder: (_) => ShippingCompanyPopup(
            selectedCompany: o.transportCompany ?? 'Sin seleccionar',
            onCompanySelected: (company) {
              Navigator.pop(ctx);
              _handleConfirmShippingCompany(ctx, o, company);
            },
          ),
        );
        break;
      case 'delivered':
        ctx.read<OrdersBloc>().add(DeliveredOrderEvent(o.id!));
        _showSnack(ctx);
        _goBackToOrders(ctx);
        break;
    }
  }

  /* Confirmar empresa de envío */
  void _handleConfirmShippingCompany(
      BuildContext ctx, OrderModel o, String company) {
    if (company == 'Sin seleccionar') {
      _showErrorDialog(ctx);
      return;
    }
    final guide = '$company-${o.id}';
    ctx.read<OrdersBloc>().add(OnTheWayTransportOrderEvent(
          orderId: o.id!,
          transportCompany: company,
          shippingGuide: guide,
        ));
    _showSnack(ctx);
    _goBackToOrders(ctx);
  }

  /* Snackbar de éxito */
  void _showSnack(BuildContext ctx) {
    final messenger = ScaffoldMessenger.of(ctx);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: darkBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            '✅ Estado actualizado correctamente',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /* Volver a OrdersScreen */
  void _goBackToOrders(BuildContext ctx) {
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => OrdersScreen(userType: userType),
      ),
      ModalRoute.withName('/'),
    );
  }

  /* Diálogo de error */
  void _showErrorDialog(BuildContext ctx) {
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
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: darkBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Aceptar', style: TextStyle(color: darkBlue)),
          ),
        ],
      ),
    );
  }
}
