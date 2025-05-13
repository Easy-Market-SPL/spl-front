import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_filter/product_filter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_filter/product_filter_event.dart';
import 'package:spl_front/bloc/product_blocs/product_filter/product_filter_state.dart';
import 'package:spl_front/bloc/product_blocs/product_form/labels/label_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_form/labels/label_event.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_bloc.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_event.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_state.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/pages/business_user/product_form.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/dashboard/active_filters_dashboard.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/dashboard/labels_dashboard.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/dashboard/products_filters_content.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/dashboard/products_filters_dialog.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/grids/business_product_grid.dart';
import 'package:spl_front/widgets/style_widgets/app_bars/business_user_app_bar.dart';
import 'package:spl_front/widgets/style_widgets/navigation_bars/nav_bar.dart';

class BusinessUserMainDashboard extends StatefulWidget {
  const BusinessUserMainDashboard({super.key});

  @override
  State<BusinessUserMainDashboard> createState() =>
      _BusinessUserMainDashboardState();
}

class _BusinessUserMainDashboardState extends State<BusinessUserMainDashboard> {
  String activeLabel = DashboardStrings.allLabels;
  late TextEditingController searchController;
  String currentSearchQuery = "";

  double? activeMinPrice;
  double? activeMaxPrice;
  double? activeMinRating;

  @override
  void initState() {
    super.initState();
    // Load products on initialization
    context.read<ProductBloc>().add(LoadProducts());
    context.read<LabelBloc>().add(LoadLabels());
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
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar with search and filter options
      appBar: BusinessUserAppBar(
        hintText: BusinessStrings.searchHint,
        searchController: searchController,
        onSearchChanged: (query) {
          context.read<ProductFilterBloc>().add(SetSearchQuery(query));
        },
        onFilterPressed: () {
          final filterState = context.read<ProductFilterBloc>().state;
          final productState = context.read<ProductBloc>().state;
          final products =
              productState is ProductLoaded ? productState.products : [];
          showDialog(
            context: context,
            builder: (context) => ProductFilterDialog(
              initialFilter: ProductFilter(
                minPrice: filterState.minPrice,
                maxPrice: filterState.maxPrice,
                minRating: filterState.minRating,
                selectedLabels: filterState.selectedLabels,
              ),
              maxProductPrice: products.isNotEmpty &&
                      filterState.maxPrice == null
                  ? products.map((p) => p.price).reduce((a, b) => a > b ? a : b)
                  : null,
              minProductPrice: products.isNotEmpty &&
                      filterState.minPrice == null
                  ? products.map((p) => p.price).reduce((a, b) => a < b ? a : b)
                  : null,
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
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Labels
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: BlocBuilder<ProductFilterBloc, ProductFilterState>(
                    builder: (context, filterState) {
                      return LabelsWidget();
                    },
                  ),
                ),

                // Active filters display
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: ActiveFiltersDisplay(),
                ),

                // Add new Product button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProductFormPage(isEditing: false),
                          ),
                        ).then((result) {
                          if (result == true) {
                            context.read<ProductBloc>().add(RefreshProducts());
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        BusinessStrings.addProduct,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildProductContent(state),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
          userType: UserType.business, context: context),
    );
  }

  Widget _buildProductContent(ProductState state) {
    if (state is ProductInitial || state is ProductLoading) {
      return const Center(child: CustomLoading());
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
          child: BusinessProductGrid(
            productsList: state.products,
          ),
        ),
      );
    }

    // Fallback
    return const Center(child: Text(ProductStrings.productLoadingError));
  }
}
