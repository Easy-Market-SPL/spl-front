import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

/// Ejemplo de widget estilo web para mostrar un OrderModel,
/// integrando la lógica de itemsCount y placeholderStatus
class OrderItemWeb extends StatelessWidget {
  final OrderModel order;
  final UserType userType;

  const OrderItemWeb({
    super.key,
    required this.order,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular la suma de ítems a partir de orderProducts
    final itemsCount =
        (order.orderProducts).fold<int>(0, (sum, op) => sum + op.quantity);

    // Determinar el estado actual de manera placeholder
    // Si existe al menos un OrderStatus, tomamos el último
    final placeholderStatus = (order.orderStatuses.isNotEmpty)
        ? order.orderStatuses.last.status
        : '(no status)';

    // Fecha de la orden (o '--' si es null)
    final creationDate = (order.creationDate == null)
        ? '--'
        : DateHelper.formatDate(order.creationDate!);

    // Placeholder de clientName si userType == business
    const clientNamePlaceholder = '(clientName_placeholder)';

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        // mainAxisSize.min para ajustar la altura del Column al contenido
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ícono y datos de la orden
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 30,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${OrderStrings.items}: $itemsCount',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      Text(
                        '${OrderStrings.orderDate}: $creationDate',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Si userType == business, mostramos un placeholder de clientName
                      if (userType == UserType.business) ...[
                        Text(
                          '${OrderStrings.client}: $clientNamePlaceholder',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                      ],

                      // Estado actual (placeholderStatus)
                      Text(
                        '${OrderStrings.status}: $placeholderStatus',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Botón centrado
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Según userType, vamos a diferentes rutas
                  if (userType == UserType.business) {
                    Navigator.of(context).pushNamed(
                      'business_user_order_tracking',
                      arguments: order,
                    );
                  } else {
                    Navigator.of(context).pushNamed(
                      'customer_user_order_tracking',
                      arguments: order,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Ver orden',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
