import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_bloc.dart';
import 'package:spl_front/bloc/ui_management/order/order_event.dart';
import 'package:spl_front/bloc/ui_management/order/order_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/order/list/order_filters_section.dart';
import 'package:spl_front/widgets/order/web/order_item_web.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

import '../../../bloc/users_blocs/users/users_bloc.dart';

class OrdersListWeb extends StatefulWidget {
  final UserType userType;

  const OrdersListWeb({super.key, required this.userType});

  @override
  State<OrdersListWeb> createState() => _OrdersListWebState();
}

class _OrdersListWebState extends State<OrdersListWeb> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<OrdersBloc>().state;
    final String userId = context.read<UsersBloc>().state.sessionUser!.id;
    if (currentState is! OrdersLoaded) {
      context.read<OrdersBloc>().add(
            LoadOrdersEvent(
              userId: userId,
              userRole: widget.userType == UserType.customer
                  ? 'customer'
                  : 'business',
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      userType: widget.userType,
      body: Row(
        children: [
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
                      final bloc = context.read<OrdersBloc>();
                      bloc.add(ApplyAdditionalFiltersEvent(filters));
                      if (dateRange != null) {
                        bloc.add(SetDateRangeEvent(dateRange));
                      } else {
                        bloc.add(const ClearDateRangeEvent());
                      }
                    },
                    onClearFilters: () {
                      final bloc = context.read<OrdersBloc>();
                      bloc.add(const ClearAdditionalFiltersEvent());
                      bloc.add(const ClearDateRangeEvent());
                    },
                    onStatusFilter: (label) {
                      context.read<OrdersBloc>().add(FilterOrdersEvent(label));
                    },
                    currentAdditionalFilters:
                        _currentAdditionalFilters(context),
                    currentDateRange: _currentDateRange(context),
                    onSearchOrders: (query) {
                      context.read<OrdersBloc>().add(SearchOrdersEvent(query));
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderStrings.ordersTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: OrdersList(userType: widget.userType),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _currentAdditionalFilters(BuildContext context) {
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      return state.additionalFilters;
    } else {
      return [];
    }
  }

  DateTimeRange? _currentDateRange(BuildContext context) {
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      return state.dateRange;
    } else {
      return null;
    }
  }
}

class OrdersList extends StatelessWidget {
  final UserType userType;

  const OrdersList({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrdersLoaded) {
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
                        child: OrderItemWeb(
                          order: order,
                          userType: userType,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        } else if (state is OrdersError) {
          return Center(child: Text(state.message));
        } else {
          return Container();
        }
      },
    );
  }
}
