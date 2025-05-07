import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_form/product_form_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_form/product_form_event.dart';
import 'package:spl_front/bloc/product_blocs/product_form/product_form_state.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_bloc.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_event.dart';
import 'package:spl_front/models/product_models/product.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/business/product_form_buttons.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/business/product_form_content.dart';

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
          _showSuccessSnackBar(
            context, 
            ProductStrings.productSaved 
          );
          
          ctx.read<ProductBloc>().add(RefreshProducts());
          Navigator.pop(ctx, true);
        } else if (state is ProductFormDeleted) {
          _showSuccessSnackBar(context, ProductStrings.productDeleted);
          
          ctx.read<ProductBloc>().add(RefreshProducts());
          Navigator.pop(ctx, true);
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
          if (!_formInitialized) {
            nameController.text = state.name;
            codeController.text = state.code;
            descriptionController.text = state.description;
            priceController.text = state.price.toString();
            _formInitialized = true;
          }
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

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any existing SnackBar
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      width: 400,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: SnackBarAction(
        label: 'CERRAR',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
}