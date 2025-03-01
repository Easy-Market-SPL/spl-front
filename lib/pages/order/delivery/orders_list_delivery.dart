import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_event.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/inputs/search_bar_input.dart';
import 'package:spl_front/widgets/navigation_bars/delivery_user_nav_bar.dart';
import 'package:spl_front/widgets/order/order_item.dart';
import 'package:spl_front/widgets/order/orders_filters_popup.dart';

// This class is exclusively for the delivery user and will be visible when the SPL Variable of RealTimeTracking is True
class OrdersScreenDelivery extends StatelessWidget {
  const OrdersScreenDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<OrderListBloc>().add(LoadOrdersEvent());
    return OrdersPageDelivery();
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
    final OrderListBloc orderListBloc = BlocProvider.of<OrderListBloc>(context);
    orderListBloc.selectedFilters = [OrderStrings.statusPreparing];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          OrderStrings.ordersTitleDelivery,
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
                                userType: UserType.delivery,
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
          const DeliveryUserBottomNavigationBar(),
        ],
      ),
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
          // Dismiss the keyboard by unfocusing the TextField
          focusNode.unfocus();

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
                      .add(ClearAdditionalFiltersDeliveryEvent());
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
