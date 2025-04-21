import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_event.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_event.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_state.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/customer_user_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/customer_user_app_bar.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';
import 'package:spl_front/widgets/products/dashboard/labels_dashboard.dart';
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
  String activeLabel = "Todos";

  @override
  void initState() {
    super.initState();
    usersBloc = BlocProvider.of<UsersBloc>(context);
    context.read<ProductBloc>().add(LoadProducts());
    context.read<LabelBloc>().add(LoadDashboardLabels());

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
  }

  @override
  Widget build(BuildContext context) {
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
            onFilterPressed: () {
              // TODO: Implement filters action
            },
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar etiquetas reales
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: LabelsWidget(
                    activeLabel: activeLabel,
                    onLabelSelected: (labelName) {
                      setState(() {
                        activeLabel = labelName;
                      });
                      context
                          .read<ProductBloc>()
                          .add(FilterProductsByCategory(labelName));
                    },
                  ),
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
