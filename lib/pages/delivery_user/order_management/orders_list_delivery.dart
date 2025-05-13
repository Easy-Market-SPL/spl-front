import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

import '../../../bloc/orders_bloc/order_bloc.dart';
import '../../../bloc/orders_bloc/order_event.dart';
import '../../../bloc/orders_bloc/order_state.dart';
import '../../../bloc/users_blocs/users/users_bloc.dart';
import '../../../models/helpers/intern_logic/user_type.dart';
import '../../../widgets/logic_widgets/order_widgets/orders/list/order_item.dart';
import '../../../widgets/style_widgets/inputs/search_bar_input.dart';
import '../../../widgets/style_widgets/navigation_bars/nav_bar.dart';

class OrdersScreenDelivery extends StatelessWidget {
  const OrdersScreenDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = context.read<UsersBloc>().state.sessionUser!.id;
    // Load orders for delivery user
    context.read<OrdersBloc>().add(
          LoadOrdersEvent(userId: userId, userRole: 'delivery'),
        );
    return const OrdersPageDelivery();
  }
}

class OrdersPageDelivery extends StatefulWidget {
  const OrdersPageDelivery({super.key});

  @override
  State<OrdersPageDelivery> createState() => _OrdersPageDeliveryState();
}

class _OrdersPageDeliveryState extends State<OrdersPageDelivery> {
  bool _deliveryPreparation = true;
  bool _didFilterInitial = false;

  @override
  Widget build(BuildContext context) {
    final String userId = context.read<UsersBloc>().state.sessionUser!.id;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          OrderStrings.ordersTitleDelivery,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        forceMaterialTransparency: true,
      ),
      body: BlocListener<OrdersBloc, OrdersState>(
        listenWhen: (prev, curr) => !_didFilterInitial && curr is OrdersLoaded,
        listener: (context, state) {
          _didFilterInitial = true;
          context.read<OrdersBloc>().add(
                FilterDeliveryOrdersEvent(preparacion: true, userId: userId),
              );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: SearchBarInput(
                focusNode: FocusNode(),
                controller: TextEditingController(),
                hintText: OrderStrings.searchOrdersHint,
                onEditingComplete: () {
                  context.read<OrdersBloc>().add(
                        SearchOrdersEvent(
                          (TextEditingController()).text,
                        ),
                      );
                },
                showFilterButton: false, // Without additional filters
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Órdenes en Preparación'),
                      selected: _deliveryPreparation,
                      onSelected: (_) {
                        setState(() => _deliveryPreparation = true);
                        context.read<OrdersBloc>().add(
                              FilterDeliveryOrdersEvent(
                                  preparacion: true, userId: userId),
                            );
                      },
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.grey[200],
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color:
                            _deliveryPreparation ? Colors.white : Colors.black,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Mis Entregas'),
                      selected: !_deliveryPreparation,
                      onSelected: (_) {
                        setState(() => _deliveryPreparation = false);
                        context.read<OrdersBloc>().add(
                              FilterDeliveryOrdersEvent(
                                  preparacion: false, userId: userId),
                            );
                      },
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.grey[200],
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color:
                            !_deliveryPreparation ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filtered orders
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(child: CustomLoading());
                  } else if (state is OrdersLoaded) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        itemCount: state.filteredOrders.length,
                        itemBuilder: (_, i) {
                          return OrderItem(
                            order: state.filteredOrders[i],
                            userType: UserType.delivery,
                            triggerFollow: _deliveryPreparation,
                          );
                        },
                      ),
                    );
                  } else if (state is OrdersError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        userType: UserType.delivery,
        context: context,
      ),
    );
  }
}
