import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

import '../../bloc/orders_bloc/order_bloc.dart';
import '../../bloc/orders_bloc/order_event.dart';
import '../../bloc/orders_bloc/order_state.dart';
import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/helpers/intern_logic/user_type.dart';
import '../../widgets/logic_widgets/order_widgets/orders/list/order_item.dart';
import '../../widgets/logic_widgets/order_widgets/orders/list/orders_filters_popup.dart';
import '../../widgets/style_widgets/inputs/search_bar_input.dart';
import '../../widgets/style_widgets/navigation_bars/nav_bar.dart';

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
    final userId = context.read<UsersBloc>().state.sessionUser!.id;
    context.read<OrdersBloc>().add(
          LoadOrdersEvent(userId: userId, userRole: userType.name),
        );
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
                          return Center(child: CustomLoading());
                        } else {
                          return CustomLoading();
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
                  ),
                  filterChip(
                    context,
                    OrderStrings.statusPreparing,
                  ),
                  filterChip(
                    context,
                    OrderStrings.statusOnTheWay,
                  ),
                  filterChip(
                    context,
                    OrderStrings.statusDelivered,
                  ),
                ],
              ),
              if (state.additionalFilters.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    for (var filter in state.additionalFilters)
                      filterChip(context, filter, isAdditionalFilter: true),
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
    bool isAdditionalFilter = false,
  }) {
    final labelFilter = {
          OrderStrings.statusConfirmed: 'confirmed',
          OrderStrings.statusPreparing: 'preparing',
          OrderStrings.statusOnTheWay: 'on-the-way',
          OrderStrings.statusDelivered: 'delivered',
        }[label] ??
        label;

    final normalSelected = context.select<OrdersBloc, bool>((bloc) {
      if (bloc.state is! OrdersLoaded) return false;
      return (bloc.state as OrdersLoaded).selectedFilters.contains(labelFilter);
    });

    final chipSelected = isAdditionalFilter ? true : normalSelected;

    return ChoiceChip(
      label: Text(label),
      selected: chipSelected,
      onSelected: (sel) {
        if (!isAdditionalFilter) {
          context.read<OrdersBloc>().add(FilterOrdersEvent(labelFilter));
        }
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: chipSelected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
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
                    ordersBloc.add(ClearAdditionalFiltersEvent());
                    ordersBloc.add(ClearDateRangeEvent());
                    currentDateRange = null;
                    currentAdditionalFilters.clear();
                  },
                  currentAdditionalFilters: currentAdditionalFilters,
                  currentDateRange: currentDateRange,
                );
              },
            );
          },
        );
      },
    );
  }
}
