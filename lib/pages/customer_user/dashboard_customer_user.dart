import 'package:flutter/material.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/customer_user_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/customer_user_app_bar.dart';
import 'package:spl_front/widgets/navigation_bars/customer_nav_bar.dart';
import 'package:spl_front/widgets/products/grids/customer_product_card.dart';
import 'package:spl_front/widgets/products/grids/customer_product_rated_card.dart';

class CustomerMainDashboard extends StatelessWidget {
  const CustomerMainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomerUserAppBar(
        hintText: CustomerStrings.searchHint, // Pass custom hint text
        onFilterPressed: () {
          // TODO: Implement filters action
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tabs
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                // TODO: Build category tabs according with the state and database info
                children: [
                  _buildCategoryTab("Todos", isSelected: true),
                  const SizedBox(width: 10),
                  _buildCategoryTab(ProductStrings.productCategory),
                  const SizedBox(width: 10),
                  _buildCategoryTab(ProductStrings.productCategory),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Product List
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // Important: Change the widget according with the variability from the Product Line
                  child: SPLVariables.isRated
                      ? CustomerProductRatedGrid()
                      : CustomerProductGrid(),
                ),
              ),
            ),

            // Bottom Navigation Bar
            CustomerBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String text, {bool isSelected = false}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          // TODO: Handle category tab selection
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
