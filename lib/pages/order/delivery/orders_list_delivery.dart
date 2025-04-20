import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/inputs/search_bar_input.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/order/list/order_item.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_event.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../bloc/users_blocs/users/users_bloc.dart';

class OrdersScreenDelivery extends StatelessWidget {
  const OrdersScreenDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = context.read<UsersBloc>().state.sessionUser!.id;
    // Carga inicial
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
  bool _deliveryPreparacion = true;
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
                showFilterButton: false, // sin filtro adicional
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
                      selected: _deliveryPreparacion,
                      onSelected: (_) {
                        setState(() => _deliveryPreparacion = true);
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
                            _deliveryPreparacion ? Colors.white : Colors.black,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Mis Entregas'),
                      selected: !_deliveryPreparacion,
                      onSelected: (_) {
                        setState(() => _deliveryPreparacion = false);
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
                            !_deliveryPreparacion ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Listado filtrado
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
                            triggerFollow: _deliveryPreparacion,
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
