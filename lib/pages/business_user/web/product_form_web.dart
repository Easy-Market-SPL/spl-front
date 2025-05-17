import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_form/product_form_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_form/product_form_event.dart';
import 'package:spl_front/bloc/product_blocs/product_form/product_form_state.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_bloc.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_event.dart';
import 'package:spl_front/models/product_models/product.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/utils/ui/snackbar_manager_web.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/business/product_form_buttons.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/business/product_form_content.dart';

void showProductFormWeb(
    BuildContext context, {
    required Product? product,
    required bool isEditing,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ProductFormWeb(
            product: product,
            isEditing: isEditing,
          ),
        ),
      ),
    );
  }

class ProductFormWeb extends StatefulWidget {
  final Product? product;
  final bool isEditing;
  const ProductFormWeb({super.key, this.product, this.isEditing = false});

  @override
  State<ProductFormWeb> createState() => _ProductFormWebState();
}

class _ProductFormWebState extends State<ProductFormWeb> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductFormBloc>().add(
      InitProductForm(productCode: widget.product?.code),
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
      listener: (ctx, state) {
        if (state is ProductFormSuccess) {
          SnackbarManager.showSuccess(context, message: ProductStrings.productSaved);
          
          ctx.read<ProductBloc>().add(RefreshProducts());
          Navigator.pop(ctx, true);
        } else if (state is ProductFormDeleted) {
          SnackbarManager.showSuccess(context, message: ProductStrings.productDeleted);
          
          ctx.read<ProductBloc>().add(RefreshProducts());
          Navigator.pop(ctx, true);
        } else if (state is ProductFormLoaded && !_formInitialized){
          nameController.text = state.name;
          codeController.text = state.code;
          descriptionController.text = state.description;
          priceController.text = state.price.toString();
          _formInitialized = true;
        }
      },
      builder: (ctx, state) {
        Widget body;
        if (state is ProductFormLoading || 
            state is ProductFormSaving || 
            state is ProductFormSuccess ||
            state is ProductFormDeleted) {
          body = const Center(child: CircularProgressIndicator());
        } else if (state is ProductFormError) {
          body = Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
        } else if (state is ProductFormLoaded) {
          body = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.isEditing
                            ? ProductStrings.editProduct
                            : ProductStrings.createProduct,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ProductFormContent(
                    isEditing: widget.isEditing,
                    nameController: nameController,
                    codeController: codeController,
                    descriptionController: descriptionController,
                    priceController: priceController,
                  ),
                ),
              ),
              // Actions buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: ProductFormButtons(
                  isEditing: widget.isEditing,
                  onSave: () {_validateAndSave();},
                  onDelete: widget.isEditing
                      ? () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(ProductStrings.deleteProduct),
                              content: Text(ProductStrings.confirmDelete),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(ProductStrings.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ctx.read<ProductFormBloc>().add(
                                          DeleteProductForm(state.productCode!),
                                        );
                                  },
                                  child: Text(ProductStrings.delete, style: const TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          );
        } else {
          body = const Center(child: Text(ProductStrings.initializingForm));
        }

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: body,
        );
      },
    );
  }

  void _validateAndSave() {
    if (nameController.text.isEmpty) {
      SnackbarManager.showWarning(
        context, message: 
        ProductStrings.requiredProductName
      );
      return;
    }

    double? price;
    try {
      String priceText = priceController.text.replaceAll(',', '');
      price = double.parse(priceText);
      if (price <= 0) throw Exception();
    } catch (e) {
      SnackbarManager.showWarning(
        context, message: 
        ProductStrings.invalidPrice
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
}