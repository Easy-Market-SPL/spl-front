import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/bloc/ui_management/order/order_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/inputs/search_bar_input.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/order/list/order_item.dart';
import 'package:spl_front/widgets/order/list/orders_filters_popup.dart';

import '../../bloc/users_blocs/users/users_bloc.dart';

class OrdersScreen extends StatefulWidget {
  final UserType userType;

  const OrdersScreen({
    super.key,
    required this.userType,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrdersPage(userType: widget.userType);
  }
}

class OrdersPage extends StatelessWidget {
  final UserType userType;

  const OrdersPage({
    super.key,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UsersBloc>().state.sessionUser?.id ?? '';
    if (userId.isNotEmpty) {
      context.read<OrdersBloc>().add(
            LoadOrdersEvent(userId: userId, userRole: userType.name),
          );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          OrderStrings.ordersTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
                  filterChips(context),
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
                                userType: userType,
                              );
                            },
                          );
                        } else if (state is OrdersError) {
                          return Center(
                              child: Text('ERROR ACAAAAA ${state.message}'));
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
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        userType: userType,
        context: context,
      ),
    );
  }

  Widget filterChips(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  filterChip(
                    context,
                    OrderStrings.statusConfirmed,
                    selected: state.selectedFilters
                        .contains(OrderStrings.statusConfirmed),
                  ),
                  filterChip(
                    context,
                    OrderStrings.statusPreparing,
                    selected: state.selectedFilters
                        .contains(OrderStrings.statusPreparing),
                  ),
                  filterChip(
                    context,
                    OrderStrings.statusOnTheWay,
                    selected: state.selectedFilters
                        .contains(OrderStrings.statusOnTheWay),
                  ),
                  filterChip(
                    context,
                    OrderStrings.statusDelivered,
                    selected: state.selectedFilters
                        .contains(OrderStrings.statusDelivered),
                  ),
                ],
              ),
              if (state.additionalFilters.isNotEmpty || state.dateRange != null)
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    for (var filter in state.additionalFilters)
                      filterChip(context, filter,
                          selected: true, isAdditionalFilter: true),
                    if (state.dateRange != null)
                      dateRangeChip(context, state.dateRange!),
                  ],
                ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget filterChip(
    BuildContext context,
    String label, {
    bool selected = false,
    bool isAdditionalFilter = false,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool isSelected) {
        if (!isAdditionalFilter) {
          context.read<OrdersBloc>().add(FilterOrdersEvent(label));
        }
      },
      selectedColor: Colors.blue,
      disabledColor: Colors.grey[300],
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      showCheckmark: false,
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
                ordersBloc.add(const ClearAdditionalFiltersEvent());
                ordersBloc.add(const ClearDateRangeEvent());
              },
              currentAdditionalFilters: currentAdditionalFilters,
              currentDateRange: currentDateRange,
            );
          },
        );
      },
    );
  }
}
