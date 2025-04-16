import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/address/address_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/order_models/order_product.dart';

import '../../bloc/ui_management/order/order_state.dart';
import '../../utils/ui/format_currency.dart';

class CartItem extends StatelessWidget {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4), // Espacio

                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8), // Espacio

                    Text(
                      formatCurrency(
                        item.product!.price * item.quantity,
                      ),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIconButton(context, Icons.remove, () {
                            if (item.quantity > 1) {
                              _updateProductQuantity(
                                  context, item.quantity - 1);
                            } else {
                              _removeProduct(context);
                            }
                          }),
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
                            _updateProductQuantity(context, item.quantity + 1);
                          }),

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

  void _updateProductQuantity(BuildContext context, int newQuantity) {
    final userId = context.read<UsersBloc>().state.sessionUser!.id;

    final address = context.read<AddressBloc>().state.addresses.first.address;

    context.read<OrdersBloc>().add(AddProductToOrderEvent(item,
        productCode: item.idProduct,
        quantity: newQuantity,
        userId: userId,
        address: address));
  }

  void _removeProduct(BuildContext context) {
    final orderState = context.read<OrdersBloc>().state;
    int? currentCartOrderId;

    if (orderState is OrdersLoaded) {
      currentCartOrderId = orderState.currentCartOrder?.id;
    }

    if (currentCartOrderId != null) {
      // Dispatch the event ONLY ONCE with the correct ID
      context.read<OrdersBloc>().add(RemoveProductFromOrderEvent(
          orderId: currentCartOrderId, productCode: item.idProduct));
    } else {
      // Show error message if cart ID cannot be determined
      debugPrint(
          "CartItem: Error - Could not find Order ID to remove product.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo determinar el carrito actual.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
