import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_event.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_state.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_event.dart';
import 'package:spl_front/bloc/ui_management/address/address_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_event.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_state.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/customer_user_strings.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/customer_user_app_bar.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/products/dashboard/active_filters_dashboard.dart';
import 'package:spl_front/widgets/products/dashboard/labels_dashboard.dart';
import 'package:spl_front/widgets/products/dashboard/products_filters_dialog.dart';
import 'package:spl_front/widgets/products/grids/customer_product_grid.dart';

import '../../bloc/ui_management/order/order_bloc.dart';
import '../../bloc/ui_management/order/order_event.dart';
import '../../widgets/helpers/custom_loading.dart';

class CustomerMainDashboard extends StatefulWidget {
  const CustomerMainDashboard({super.key});

  @override
  State<CustomerMainDashboard> createState() => _CustomerMainDashboardState();
}

class _CustomerMainDashboardState extends State<CustomerMainDashboard> {
  late UsersBloc usersBloc;
  String activeLabel = DashboardStrings.allLabels;
  late TextEditingController searchController;
  String currentSearchQuery = "";

  double? activeMinPrice;
  double? activeMaxPrice;
  double? activeMinRating;

  @override
  void initState() {
    super.initState();
    usersBloc = BlocProvider.of<UsersBloc>(context);

    // Fetch the current user's orders, passing role=consumer
    final userId = usersBloc.state.sessionUser?.id ?? '';
    if (userId.isNotEmpty) {
      context.read<OrdersBloc>().add(
            LoadOrdersEvent(
              userId: userId,
              userRole: 'customer',
            ),
          );
    }

    // Fetch the current user's addresses
    context.read<AddressBloc>().add(LoadAddresses(userId));

    context.read<ProductBloc>().add(LoadProducts());
    context.read<LabelBloc>().add(LoadDashboardLabels());
    context.read<ProductFilterBloc>().add(InitFilters());

    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<ProductBloc>().add(LoadProducts());

    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, usersSstate) {
        if (usersSstate.sessionUser == null) {
          return Scaffold(
            body: Center(
              child: CustomLoading(),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomerUserAppBar(
            hintText: CustomerStrings.searchHint, // Pass custom hint text
            searchController: searchController,
            onSearchChanged: (query){
              context.read<ProductFilterBloc>().add(SetSearchQuery(query));
            },
            onFilterPressed: () {
              final filterState = context.read<ProductFilterBloc>().state;
              final productState = context.read<ProductBloc>().state;
              final products = productState is ProductLoaded ? productState.products : [];
              showDialog(
                context: context,
                builder: (context) => ProductFilterDialog(
                  initialFilter: ProductFilter(
                    minPrice: filterState.minPrice,
                    maxPrice: filterState.maxPrice,
                    minRating: filterState.minRating,
                    selectedLabels: filterState.selectedLabels,
                  ),
                  maxProductPrice: products.isNotEmpty && filterState.maxPrice == null ? products.map((p) => p.price).reduce((a, b) => a > b ? a : b) : null,
                  minProductPrice: products.isNotEmpty && filterState.minPrice == null ? products.map((p) => p.price).reduce((a, b) => a < b ? a : b) : null,
                ),
              ).then((result) {
                if (result != null && result is ProductFilter) {
                  context.read<ProductFilterBloc>().add(
                    ApplyFiltersFromDialog(
                      minPrice: result.minPrice,
                      maxPrice: result.maxPrice,
                      minRating: result.minRating,
                      selectedLabels: result.selectedLabels,
                    ),
                  );
                }
              });
            },
          ),

          // Screen content
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Labels 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: BlocBuilder<ProductFilterBloc, ProductFilterState>(
                    builder: (context, filterState) {
                      return LabelsWidget();
                    },
                  ),
                ),

                // Active filters display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ActiveFiltersDisplay(),
                ),

                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, productState) {
                      return _buildProductContent(productState);
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            userType: UserType.customer,
            context: context,
          ),
        );
      },
    );
  }

  Widget _buildProductContent(ProductState state) {
    if (state is ProductInitial || state is ProductLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProductError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ProductStrings.productLoadingError,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ProductBloc>().add(LoadProducts()),
              child: const Text(ProductStrings.retry),
            ),
          ],
        ),
      );
    } else if (state is ProductLoaded) {
      if (state.products.isEmpty) {
        return const Center(
          child: Text(
            ProductStrings.noProductsAvailable,
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomerProductGrid(
            productsList: state.products,
          ),
        ),
      );
    }

    // Fallback
    return const Center(child: Text(ProductStrings.productLoadingError));
  }
}
