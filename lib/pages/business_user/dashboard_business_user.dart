import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/business_user_app_bar.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/products/grids/business_product_grid.dart';

class BusinessUserMainDashboard extends StatelessWidget {
  const BusinessUserMainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BusinessUserAppBar(
        hintText: BusinessStrings.searchHint,
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

            // Button for add new product
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 4.0),
              child: SizedBox(
                width: double.infinity, // Ensures the button takes full width
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement add product logic
                    Navigator.pushNamed(context, 'add_product');
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

            // Product List
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // Important: Change the widget according with the variability from the Product Line
                  child: BusinessProductGrid()
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(userType: UserType.business, context: context,),
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
