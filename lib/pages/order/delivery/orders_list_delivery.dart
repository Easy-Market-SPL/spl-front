import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/inputs/search_bar_input.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/order/list/order_item.dart';
import 'package:spl_front/widgets/order/list/orders_filters_popup.dart';

import '../../../bloc/ui_management/order/order_bloc.dart';
import '../../../bloc/ui_management/order/order_event.dart';
import '../../../bloc/ui_management/order/order_state.dart';
import '../../../bloc/users_blocs/users/users_bloc.dart';
import '../../../models/order_models/order_model.dart';

class OrdersScreenDelivery extends StatelessWidget {
  const OrdersScreenDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = context.read<UsersBloc>().state.sessionUser!.id;
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
  @override
  void initState() {
    super.initState();
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      final selected = state.selectedFilters.toList();
      if (!selected.contains(OrderStrings.statusPreparing)) {
        selected.add(OrderStrings.statusPreparing);
      }
      if (!selected.contains(OrderStrings.statusOnTheWay)) {
        selected.add(OrderStrings.statusOnTheWay);
      }
      final filtered = _applyStatusFilters(state.allOrders, selected);
      context.read<OrdersBloc>().emit(
            state.copyWith(
              selectedFilters: selected,
              filteredOrders: filtered,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          OrderStrings.ordersTitleDelivery,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                children: [
                  searchBar(context),
                  Expanded(
                    child: BlocBuilder<OrdersBloc, OrdersState>(
                      builder: (context, state) {
                        if (state is OrdersLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is OrdersLoaded) {
                          return ListView.builder(
                            itemCount: state.filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = state.filteredOrders[index];
                              return OrderItem(
                                order: order,
                                userType: UserType.delivery,
                              );
                            },
                          );
                        } else if (state is OrdersError) {
                          return Center(child: Text(state.message));
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomBottomNavigationBar(
            userType: UserType.delivery,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    final focusNode = FocusNode();
    final controller = TextEditingController();

    return SearchBarInput(
      focusNode: focusNode,
      controller: controller,
      hintText: OrderStrings.searchOrdersHint,
      onEditingComplete: () {
        context.read<OrdersBloc>().add(SearchOrdersEvent(controller.text));
      },
      showFilterButton: true,
      onFilterPressed: () async {
        focusNode.unfocus();
        final ordersBloc = context.read<OrdersBloc>();
        final currentState = ordersBloc.state;
        List<String> currentAdditionalFilters = [];
        DateTimeRange? currentDateRange;

        if (currentState is OrdersLoaded) {
          currentAdditionalFilters = currentState.additionalFilters;
          currentDateRange = currentState.dateRange;
        }
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return FiltersPopup(
              onApplyFilters: (filters, dateRange) {
                ordersBloc.add(ApplyAdditionalFiltersEvent(filters));
                if (dateRange != null) {
                  ordersBloc.add(SetDateRangeEvent(dateRange));
                } else {
                  ordersBloc.add(const ClearDateRangeEvent());
                }
              },
              onClearFilters: () {
                // Este evento solo existe en tu BLoC si lo definiste
                // Si quieres restablecer los filtros para 'delivery', ajusta la lógica
                // Ej:
                ordersBloc.add(const ClearAdditionalFiltersEvent());
              },
              currentAdditionalFilters: currentAdditionalFilters,
              currentDateRange: currentDateRange,
            );
          },
        );
      },
    );
  }

  Widget dateRangeChip(BuildContext context, DateTimeRange dateRange) {
    final String startDate = DateHelper.formatDate(dateRange.start);
    final String endDate = DateHelper.formatDate(dateRange.end);
    return ChoiceChip(
      label: Text(OrderStrings.showDateRangeString(startDate, endDate)),
      selected: true,
      onSelected: (_) {},
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      showCheckmark: false,
    );
  }

  List<OrderModel> _applyStatusFilters(
      List<OrderModel> orders, List<String> statuses) {
    // Suponiendo que cada order no tiene un 'status' directo sino 'orderStatuses'.
    // Ejemplo: busco el último status y veo si coincide
    return orders.where((o) {
      if (o.orderStatuses == null || o.orderStatuses!.isEmpty) return false;
      final lastStatus = o.orderStatuses!.last.status;
      return statuses.contains(lastStatus);
    }).toList();
  }
}
