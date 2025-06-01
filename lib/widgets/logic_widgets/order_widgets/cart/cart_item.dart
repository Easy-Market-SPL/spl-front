import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/order_models/order_product.dart';

import '../../../../bloc/orders_bloc/order_bloc.dart';
import '../../../../bloc/orders_bloc/order_event.dart';
import '../../../../bloc/orders_bloc/order_state.dart';
import '../../../../bloc/users_session_information_blocs/address_bloc/address_bloc.dart';
import '../../../../utils/ui/format_currency.dart';

class CartItem extends StatelessWidget {
  final OrderProduct item;
  final bool isWeb;

  const CartItem({super.key, 
    required this.item,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    if (item.product == null) {
      debugPrint(
          'Error: CartItem recibió un item sin producto cargado: ${item.idProduct}');
      return const SizedBox.shrink();
    }

    return isWeb 
        ? _buildWebCartItem(context)
        : _buildProductDetails(context);
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
    final addresses = context.read<AddressBloc>().state.addresses;

    var address = addresses.isNotEmpty
        ? addresses.first.address
        : "Pending";

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

  Widget _buildWebCartItem(BuildContext context) {
    final product = item.product!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                product.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Product description
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Bottom row with quantity controls and price
                Row(
                  children: [
                    // Quantity controls
                    Row(
                      children: [
                        _buildIconButton(context, Icons.remove, () {
                          if (item.quantity > 1) {
                            _updateProductQuantity(context, item.quantity - 1);
                          } else {
                            _removeProduct(context);
                          }
                        }),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        _buildIconButton(context, Icons.add, () {
                          _updateProductQuantity(context, item.quantity + 1);
                        }),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(product.price * item.quantity),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${formatCurrency(product.price)} c/u',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Remove button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeProduct(context),
                      tooltip: 'Eliminar del carrito',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
