import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_state.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/product_view_app_bar.dart';
import 'package:spl_front/widgets/products/business/product_form_buttons.dart';
import 'package:spl_front/widgets/products/business/product_form_content.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final bool isEditing;

  const ProductFormPage({
    super.key,
    this.product,
    this.isEditing = false,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize the ProductFormBloc
    context.read<ProductFormBloc>().add(
      InitProductForm(
        productCode: widget.product?.code,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductFormBloc, ProductFormState>(
      listener: _productFormListener,
      builder: (context, state) {
        return Scaffold(
          appBar: ProductViewAppBar(
            appBarTittle: widget.isEditing
                ? ProductStrings.editProduct
                : ProductStrings.createProduct,
            userType: UserType.business,
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Form content
              if (state is ProductFormSaving)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state is ProductFormLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state is ProductFormLoaded)
                Expanded(child: ProductFormContent(
                  isEditing: widget.isEditing,
                  nameController: nameController,
                  codeController: codeController,
                  descriptionController: descriptionController,
                  priceController: priceController,
                ))
              else
                const Expanded(
                  child: Center(child: Text(ProductStrings.initializingForm)),
                ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ProductFormButtons(
                        isEditing: widget.isEditing,
                        onSave: _validateAndSave,
                        onDelete: widget.isEditing ? _handleDelete : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _productFormListener(BuildContext context, ProductFormState state) {
    if (state is ProductFormSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      Navigator.pop(context, true);
    } else if (state is ProductFormError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error), backgroundColor: Colors.red),
      );
    } else if (state is ProductFormDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      Navigator.pop(context, true);
    } else if (state is ProductFormLoaded && !_formInitialized) {
      // Initialize form fields
      nameController.text = state.name;
      codeController.text = state.code;
      descriptionController.text = state.description;
      priceController.text = state.price.toString();
      _formInitialized = true;
    }
  }

  void _validateAndSave() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ProductStrings.requiredProductName)),
      );
      return;
    }
  
    double? price;
    try {
      String priceText = priceController.text.replaceAll(',', '');
      price = double.parse(priceText);
      if (price <= 0) throw Exception();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ProductStrings.invalidPrice)),
      );
      return;
    }
  
    // Dispatch SaveProductForm event
    final currentState = context.read<ProductFormBloc>().state;
    if (currentState is ProductFormLoaded) {
      context.read<ProductFormBloc>().add(SaveProductForm(
        name: nameController.text,
        code: codeController.text,
        description: descriptionController.text,
        price: price,
        imagePath: currentState.imagePath,
        colors: currentState.colors,
        labels: currentState.labels,
        variants: currentState.variants,
      ));
    }
  }

  void _handleDelete() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ProductStrings.deleteProduct),
        content: const Text(ProductStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(ProductStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              // Close dialog
              Navigator.pop(context);
              
              // Dispatch DeleteProductForm event
              final currentState = context.read<ProductFormBloc>().state;
              if (currentState is ProductFormLoaded) {
                if (currentState.productCode != null) {
                  context.read<ProductFormBloc>().add(
                    DeleteProductForm(currentState.productCode!),
                  );
                }
              }
            },
            child: const Text(ProductStrings.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}