import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/orders_bloc/order_bloc.dart';
import 'package:spl_front/bloc/orders_bloc/order_event.dart';
import 'package:spl_front/bloc/orders_bloc/order_state.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/models/order_models/order_product.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/utils/strings/cart_strings.dart';
import 'package:spl_front/utils/ui/format_currency.dart';
import 'package:spl_front/utils/ui/snackbar_manager_web.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/logic_widgets/order_widgets/cart/cart_item.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

class CartWebPage extends StatefulWidget {
  const CartWebPage({super.key});

  @override
  State<CartWebPage> createState() => _CartWebPageState();
}

class _CartWebPageState extends State<CartWebPage> {
  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  void _loadCartData() {
    final ordersBloc = context.read<OrdersBloc>();
    final usersBloc = context.read<UsersBloc>();
    final userId = usersBloc.state.sessionUser?.id;

    if (userId != null) {
      ordersBloc.add(LoadOrdersEvent(userId: userId, userRole: 'customer'));
    } else {
      debugPrint("Error: User ID not found in initState of CartWebPage.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      userType: UserType.customer,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              if (state is OrdersInitial || state is OrdersLoading) {
                return const Center(child: CustomLoading());
              } else if (state is OrdersLoaded) {
                final bool hasItems = state.currentCartOrder != null &&
                    state.currentCartOrder!.orderProducts.isNotEmpty;
                
                if (hasItems) {
                  return _buildCartWithItems(
                    state.currentCartOrder!.orderProducts,
                    context,
                    state.isLoading,
                  );
                } else {
                  return _buildEmptyCart(context);
                }
              } else if (state is OrdersError) {
                debugPrint("OrdersError state in CartWebPage: ${state.message}");
                return _buildEmptyCart(context);
              } else {
                return _buildEmptyCart(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 32),
                Text(
                  CartStrings.emptyCartMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'customer_dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continuar Comprando',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartWithItems(
    List<OrderProduct> items,
    BuildContext context,
    bool isLoading,
  ) {
    // Calculate totals
    double subtotal = items.fold(0.0,
                (sum, item) => sum! + item.product!.price * item.quantity) ??
            0.0;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Cart items list
          Expanded(
            flex: 3,
            child: Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart title
                    Row(
                      children: [
                        Text(
                          '${CartStrings.cartTitle} (${items.length} ${items.length == 1 ? 'item' : 'items'})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: Text(
                            CartStrings.clearCartButton,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            context.read<OrdersBloc>().add(ClearCartEvent());
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Items list
                    Expanded(
                      child: items.isEmpty
                          ? const Center(
                              child: Text('El carrito está vacío'),
                            )
                          : ListView.separated(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return CartItem(
                                  key: ValueKey(item.idProduct),
                                  item: item,
                                  isWeb: true,
                                );
                              },
                              separatorBuilder: (context, index) => const Divider(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Right column - Order summary
          Expanded(
            flex: 2,
            child: Card(
              elevation: 2,
              color: PrimaryColors.blueWeb,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Resumen del pedido',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency(subtotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Checkout button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading || items.isEmpty
                            ? null
                            : () => _onCheckoutPressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoading
                              ? Colors.grey
                              : const Color.fromARGB(255, 0, 93, 180),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                CartStrings.checkoutButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Continue shopping button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, 'customer_dashboard');
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Continuar comprando',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCheckoutPressed(BuildContext context) {
    SnackbarManager.showInfo(
      context,
      message: 'Procesando su orden...',
    );
    
    // Navigate to checkout page or show checkout dialog
    Navigator.pushNamed(context, 'customer_payment');
  }
}