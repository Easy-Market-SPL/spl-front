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
import 'package:spl_front/pages/business_user/web/product_form_web.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/dashboard/active_filters_dashboard.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/dashboard/products_filters_content.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/dashboard/products_filters_dialog.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/grids/business_product_grid.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

class DashboardBusinessWeb extends StatefulWidget {
  const DashboardBusinessWeb({super.key});

  @override
  State<DashboardBusinessWeb> createState() => _DashboardBusinessWebState();
}

class _DashboardBusinessWebState extends State<DashboardBusinessWeb> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize product and filter blocs
    context.read<ProductBloc>().add(LoadProducts());
    context.read<LabelBloc>().add(LoadLabels());
    context.read<ProductFilterBloc>().add(InitFilters());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    
    return WebScaffold(
      userType: UserType.business,
      body: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters sidebar (collapsible on medium screens)
                  if (isLargeScreen || isMediumScreen)
                    SizedBox(
                      width: isLargeScreen ? 280 : 220,
                      child: BlocBuilder<ProductBloc, ProductState>(
                        builder: (_, prodState) => BlocBuilder<ProductFilterBloc, ProductFilterState>(
                          builder: (__, filterState) {
                            double? minP, maxP;
                            if (prodState is ProductLoaded && prodState.products.isNotEmpty) {
                              final prices = prodState.products.map((p) => p.price);
                              minP = filterState.minPrice ?? prices.reduce((a,b) => a<b?a:b);
                              maxP = filterState.maxPrice ?? prices.reduce((a,b) => a>b?a:b);
                            }
                            return Card(
                              elevation: 2,
                              color: PrimaryColors.blueWeb,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: ProductFiltersForm(
                                          initialFilter: ProductFilter(
                                            minPrice: filterState.minPrice,
                                            maxPrice: filterState.maxPrice,
                                            minRating: filterState.minRating,
                                            selectedLabels: filterState.selectedLabels,
                                          ),
                                          minProductPrice: minP,
                                          maxProductPrice: maxP,
                                          onApply: (f) {
                                            context.read<ProductFilterBloc>().add(
                                              ApplyFiltersFromDialog(
                                                minPrice: f.minPrice,
                                                maxPrice: f.maxPrice,
                                                minRating: f.minRating,
                                                selectedLabels: f.selectedLabels,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Clear filters button
                                    TextButton(
                                      onPressed: () {
                                        context.read<ProductFilterBloc>().add(InitFilters());
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                      ),
                                      child: const Text(DashboardStrings.cleanFilters, 
                                          style: TextStyle(color: Colors.black)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                  if (isLargeScreen || isMediumScreen) 
                    const SizedBox(width: 24),
                    
                  // Products Grid
                  Expanded(
                    child: Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DashboardStrings.products,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!isLargeScreen && !isMediumScreen)
                                  IconButton(
                                    icon: const Icon(Icons.filter_list),
                                    onPressed: () {
                                      _showFiltersDialog(context);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Active filters display (only on small screens)
                            if (!isLargeScreen && !isMediumScreen)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                child: ActiveFiltersDisplay(),
                              ),
                              const SizedBox(height: 8),
                            
                            // Create product button
                            ElevatedButton.icon(
                              onPressed: () {
                                showProductFormWeb(context, isEditing: false, product: null);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text("Crear producto", 
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                            ),
                            const SizedBox(height: 8),
                            
                            // Products content
                            Expanded(
                              child: BlocBuilder<ProductBloc, ProductState>(
                                builder: (context, state) {
                                  return _buildProductContent(state);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

      return BusinessProductGrid(
        productsList: state.products,
      );
    }

    // Fallback
    return const Center(child: Text(ProductStrings.productLoadingError));
  }

  void _showFiltersDialog(BuildContext context) {
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
        maxProductPrice:
            products.isNotEmpty && filterState.maxPrice == null
                ? products
                    .map((p) => p.price)
                    .reduce((a, b) => a > b ? a : b)
                : null,
        minProductPrice:
            products.isNotEmpty && filterState.minPrice == null
                ? products
                    .map((p) => p.price)
                    .reduce((a, b) => a < b ? a : b)
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
  }
}