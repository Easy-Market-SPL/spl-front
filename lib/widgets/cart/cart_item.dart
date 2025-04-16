import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/order_models/order_product.dart';

import '../../bloc/ui_management/order/order_state.dart';

class CartItem extends StatelessWidget {
  // Convertido a StatelessWidget
  final OrderProduct item;

  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.product == null) {
      debugPrint(
          'Error: CartItem recibió un item sin producto cargado: ${item.idProduct}');
      return const SizedBox.shrink();
    }

    return _buildProductDetails(context);
  }

  Widget _buildProductDetails(BuildContext context) {
    final product = item.product!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 14, right: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                product.imagePath,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Ajusta según necesites
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2, // Evita overflow si el nombre es muy largo
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Espacio
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2, // Evita overflow
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8), // Espacio
                    Text(
                      // Formateo de precio podría ser mejorado (ej. con intl package)
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14), // Tamaño un poco más grande
                    ),
                    // Alineación de controles al final
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIconButton(context, Icons.remove, () {
                            // Lógica para decrementar cantidad
                            if (item.quantity > 1) {
                              // Solo actualiza si es > 1
                              _updateProductQuantity(
                                  context, item.quantity - 1);
                            } else {
                              // Si la cantidad es 1, el botón de remover debería actuar como eliminar
                              _removeProduct(context);
                            }
                          }),
                          // Padding para que el número no esté pegado a los botones
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildIconButton(context, Icons.add, () {
                            // Lógica para incrementar cantidad
                            _updateProductQuantity(context, item.quantity + 1);
                          }),
                          // Separar un poco el botón de eliminar
                          const SizedBox(width: 10),
                          _buildIconButton(context, Icons.delete_outline, () {
                            _removeProduct(context);
                          },
                              color: Colors
                                  .redAccent), // Color más distintivo para eliminar
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función para actualizar la cantidad (simplificada)
  void _updateProductQuantity(BuildContext context, int newQuantity) {
    // Ya no necesitamos AddressBloc aquí si la dirección se maneja al crear/confirmar la orden
    final userId = context.read<UsersBloc>().state.sessionUser?.id;
    if (userId == null) {
      debugPrint("Error: Usuario no encontrado para actualizar cantidad.");
      // Manejar el caso de usuario no logueado si es posible
      return;
    }
    // La dirección debería estar en la orden principal (currentCartOrder)
    // No es necesario pasarla explícitamente aquí si el BLoC ya la conoce
    // o si la orden ya existe.

    context.read<OrdersBloc>().add(AddProductToOrderEvent(
          // Probablemente no necesites pasar el 'item' completo,
          // solo los identificadores y la nueva cantidad.
          // Verifica tu evento AddProductToOrderEvent. Asumiendo que necesita el item:
          item, // O crea un nuevo OrderProduct si es necesario por el evento
          productCode: item.idProduct,
          quantity: newQuantity,
          userId: userId,
          address:
              '', // Dejar vacío o obtener del estado de OrdersBloc si es necesario
          // para *crear* una nueva orden si no existe.
          // Si la orden (carrito) ya existe, el BLoC debería usar su ID.
        ));

    // ---- ¡NO LLAMAR A LoadOrdersEvent AQUÍ! ----
    // El BLoC se encargará de emitir el nuevo estado OrdersLoaded
    // con la información actualizada después de procesar AddProductToOrderEvent.
  }

  // Función para remover el producto
  void _removeProduct(BuildContext context) {
    final orderState = context.read<OrdersBloc>().state;
    if (orderState is OrdersLoaded && orderState.currentCartOrder?.id != null) {
      context.read<OrdersBloc>().add(RemoveProductFromOrderEvent(
          orderId: orderState
              .currentCartOrder!.id!, // Usa el ID del carrito del BLoC
          productCode: item.idProduct));
    } else {
      debugPrint(
          "Error: No se pudo obtener un ID de orden válido para remover el producto.");
    }

    context.read<OrdersBloc>().add(RemoveProductFromOrderEvent(
        orderId: item.idOrder, productCode: item.idProduct));
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, VoidCallback onPressed,
      {Color color = Colors.grey}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, size: 22, color: color),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
