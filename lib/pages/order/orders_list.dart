import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_event.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/inputs/search_bar_input.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/order/list/order_item.dart';
import 'package:spl_front/widgets/order/list/orders_filters_popup.dart';

class OrdersScreen extends StatelessWidget {
  final UserType userType;

  const OrdersScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    context.read<OrderListBloc>().add(LoadOrdersEvent());
    return OrdersPage(userType: userType);
  }
}

class OrdersPage extends StatelessWidget {
  final UserType userType;

  const OrdersPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          OrderStrings.ordersTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                children: [
                  searchBar(context),
                  filterChips(context),
                  Expanded(
                    child: BlocBuilder<OrderListBloc, OrderListState>(
                      builder: (context, state) {
                        if (state is OrderListLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is OrderListLoaded) {
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
                        } else if (state is OrderListError) {
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
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(userType: userType),
    );
  }

  Widget filterChips(BuildContext context) {
    return BlocBuilder<OrderListBloc, OrderListState>(
      builder: (context, state) {
        if (state is OrderListLoaded) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  filterChip(context, OrderStrings.statusConfirmed,
                      selected: state.selectedFilters
                          .contains(OrderStrings.statusConfirmed)),
                  filterChip(context, OrderStrings.statusPreparing,
                      selected: state.selectedFilters
                          .contains(OrderStrings.statusPreparing)),
                  filterChip(context, OrderStrings.statusOnTheWay,
                      selected: state.selectedFilters
                          .contains(OrderStrings.statusOnTheWay)),
                  filterChip(context, OrderStrings.statusDelivered,
                      selected: state.selectedFilters
                          .contains(OrderStrings.statusDelivered)),
                ],
              ),
              if (state.additionalFilters.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    ...state.additionalFilters.map((filter) => filterChip(
                        context, filter,
                        selected: true, isAditionalFilter: true)),
                    if (state.selectedDateRange != null)
                      dateRangeChip(context, state.selectedDateRange!),
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

  Widget filterChip(BuildContext context, String label,
      {bool selected = false, bool isAditionalFilter = false}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool selected) {
        if (!isAditionalFilter) {
          context.read<OrderListBloc>().add(FilterOrdersEvent(label));
        }
      },
      selectedColor: Colors.blue,
      disabledColor: Colors.grey[300],
      labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black, fontSize: 12),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      showCheckmark: false,
    );
  }

  Widget dateRangeChip(BuildContext context, DateTimeRange dateRange) {
    final String startDate = DateHelper.formatDate(dateRange.start);
    final String endDate = DateHelper.formatDate(dateRange.end);
    return ChoiceChip(
      label: Text(OrderStrings.showDateRangeString(startDate, endDate)),
      selected: true,
      onSelected: (bool selected) {
        // Do nothing, chip is always selected
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      showCheckmark: false,
    );
  }

  Widget searchBar(BuildContext context) {
    // Create a FocusNode to control the TextField focus
    final FocusNode focusNode = FocusNode();
    final TextEditingController controller = TextEditingController();

    return SearchBarInput(
        focusNode: focusNode,
        controller: controller,
        hintText: OrderStrings.searchOrdersHint,
        onEditingComplete: () {
          context.read<OrderListBloc>().add(SearchOrdersEvent(controller.text));
        },
        showFilterButton: true,
        onFilterPressed: () async {
          final List<String> currentAdditionalFilters =
              context.read<OrderListBloc>().state is OrderListLoaded
                  ? (context.read<OrderListBloc>().state as OrderListLoaded)
                      .additionalFilters
                  : [];
          final DateTimeRange? currentDateRange =
              context.read<OrderListBloc>().state is OrderListLoaded
                  ? (context.read<OrderListBloc>().state as OrderListLoaded)
                      .selectedDateRange
                  : null;

          // Show the popup
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return FiltersPopup(
                onApplyFilters: (filters, dateRange) {
                  context
                      .read<OrderListBloc>()
                      .add(ApplyAdditionalFiltersEvent(filters));
                  context.read<OrderListBloc>().selectedDateRange = dateRange;
                },
                onClearFilters: () {
                  context
                      .read<OrderListBloc>()
                      .add(ClearAdditionalFiltersEvent());
                  context.read<OrderListBloc>().selectedDateRange = null;
                },
                currentAdditionalFilters: currentAdditionalFilters,
                currentDateRange: currentDateRange,
              );
            },
          );
        });
  }
}
