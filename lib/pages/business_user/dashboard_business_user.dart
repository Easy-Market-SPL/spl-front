import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_event.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/pages/business_user/product_form.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/business_user_app_bar.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/products/grids/business_product_grid.dart';

class BusinessUserMainDashboard extends StatefulWidget {
  const BusinessUserMainDashboard({super.key});

  @override
  State<BusinessUserMainDashboard> createState() => _BusinessUserMainDashboardState();
}

class _BusinessUserMainDashboardState extends State<BusinessUserMainDashboard> {
  final List<String> categories = ["Todos", "Ropa", "Accesorios", "Electrónicos"];
  
  @override
  void initState() {
    super.initState();
    // Load products on initialization
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BusinessUserAppBar(
        hintText: BusinessStrings.searchHint,
        onFilterPressed: () {
          // Implement filters action
        },
      ),
      body: SafeArea(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tabs
                _buildCategoryTabs(state),
                const SizedBox(height: 8),

                // Button for add new product
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to add product screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductFormPage(isEditing: false),
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

                // Product List with different states
                Expanded(
                  child: _buildProductContent(state),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(userType: UserType.business, context: context),
    );
  }

  Widget _buildCategoryTabs(ProductState state) {
    String activeCategory = "Todos";
    
    if (state is ProductLoaded) {
      activeCategory = state.activeCategory;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = category == activeCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildCategoryTab(
                category, 
                isSelected: isSelected,
                onPressed: () {
                  context.read<ProductBloc>().add(
                    FilterProductsByCategory(category)
                  );
                }
              ),
            );
          }).toList(),
        ),
      ),
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
          child: BusinessProductGrid(
            productsList: state.products,
          ),
        ),
      );
    }
    
    // Fallback
    return const Center(child: Text(ProductStrings.productLoadingError));
  }

  Widget _buildCategoryTab(String text, {bool isSelected = false, VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}