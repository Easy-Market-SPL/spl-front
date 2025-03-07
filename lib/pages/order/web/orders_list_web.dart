import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_bloc.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_event.dart';
import 'package:spl_front/bloc/ui_management/orders_list/orders_list_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/order/list/order_filters_section.dart';
import 'package:spl_front/widgets/order/web/order_item_web.dart';

class OrdersListWeb extends StatelessWidget {
  final UserType userType;

  const OrdersListWeb({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    context.read<OrderListBloc>().add(LoadOrdersEvent());
    return Scaffold(
      body: Row(
        children: [
          // Filters Section
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topLeft,
              color: PrimaryColors.blueWeb,
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: FiltersSection(
                    onApplyFilters: (filters, dateRange) {
                      context.read<OrderListBloc>().selectedDateRange = dateRange;
                      context
                        .read<OrderListBloc>()
                        .add(ApplyAdditionalFiltersEvent(filters));
                    },
                    onClearFilters: () {
                      context
                          .read<OrderListBloc>()
                          .add(ClearAdditionalFiltersEvent());
                      context.read<OrderListBloc>().selectedDateRange = null;
                    },
                    onStatusFilter: (label) {
                      context.read<OrderListBloc>().add(FilterOrdersEvent(label));
                    },
                    currentAdditionalFilters: context.read<OrderListBloc>().state is OrderListLoaded
                      ? (context.read<OrderListBloc>().state as OrderListLoaded)
                          .additionalFilters
                      : [],
                    currentDateRange: context.read<OrderListBloc>().state is OrderListLoaded
                      ? (context.read<OrderListBloc>().state as OrderListLoaded)
                          .selectedDateRange
                      : null,
                    onSearchOrders: (query){
                      context.read<OrderListBloc>().add(SearchOrdersEvent(query));
                    },
                  )
                )
              ),
            ),
          ),
          
          // Orders List
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderStrings.ordersTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: OrdersList(userType: userType),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final UserType userType;

  const OrdersList({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderListBloc, OrderListState>(
      builder: (context, state) {
        if (state is OrderListLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is OrderListLoaded) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(0),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10,
                    runSpacing: 10,
                    children: state.filteredOrders.map((order) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: OrderItemWeb(order: order, userType: userType),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        } else if (state is OrderListError) {
          return Center(child: Text(state.message));
        } else {
          return Container();
        }
      },
    );
  }
}