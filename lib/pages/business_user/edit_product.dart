import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_state.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/utils/strings/business_user_strings.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/app_bars/business_user_back_app_bar.dart';
import 'package:spl_front/widgets/products/pickers/product_image_picker.dart';
import 'package:spl_front/widgets/products/view/color/product_colors.dart';
import 'package:spl_front/widgets/products/view/product_info.dart';
import 'package:spl_front/widgets/products/view/labels/product_label_picker.dart';
import 'package:spl_front/widgets/products/view/product_variants.dart';

class ProductBusinessPage extends StatefulWidget {
  final Product? product;
  final bool isEditing;

  const ProductBusinessPage({
    super.key,
    this.product,
    this.isEditing = false,
  });

  @override
  State<ProductBusinessPage> createState() => _ProductBusinessPageState();
}

class _ProductBusinessPageState extends State<ProductBusinessPage> {
  // Controllers for the product fields
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores vacíos
    nameController = TextEditingController();
    codeController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController(text: '0.0');
    
    // Iniciar el formulario con o sin un producto existente
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
      listener: (context, state) {
        if (state is ProductFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context);
        } else if (state is ProductFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is ProductFormDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context);
        } else if (state is ProductFormLoaded) {
          // Actualizar controladores con los datos cargados
          nameController.text = state.name;
          codeController.text = state.code;
          descriptionController.text = state.description;
          priceController.text = state.price.toString();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: BusinessUserBackAppBar(
            hintText: BusinessStrings.searchHint,
            onFilterPressed: () {},
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Title bar (shows "Edit Product" or "Create Product")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  state is ProductFormLoaded && state.isEditing 
                      ? "Editar Producto" 
                      : "Crear Producto",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              if (state is ProductFormSaving)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Guardando producto..."),
                      ],
                    ),
                  ),
                )
              else if (state is ProductFormLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is ProductFormLoaded)
                // Formulario principal
                Expanded(
                  child: _buildForm(context, state),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text("Inicializando formulario..."),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, ProductFormLoaded state) {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Picker
                  ProductImagePickerWidget(
                    // initialImageUrl: state.imagePath,
                    // onImageSelected: (path) {
                    //   context.read<ProductFormBloc>().add(UpdateProductImage(path));
                    // },
                  ),

                  SizedBox(height: 5),
                  // Color picker
                  ColorPickerWidget(
                    initialColors: state.colors,
                    onColorsChanged: (newColors) {
                      // Si hay más colores, se añadió uno
                      if (newColors.length > state.colors.length) {
                        final newColor = newColors.last;
                        context.read<ProductFormBloc>().add(AddProductColor(newColor));
                      } 
                      // Si hay menos colores, se eliminó uno
                      else if (newColors.length < state.colors.length) {
                        // Encontrar qué color falta
                        for (int i = 0; i < state.colors.length; i++) {
                          bool found = false;
                          for (var newColor in newColors) {
                            if (newColor.idColor == state.colors[i].idColor &&
                                newColor.name == state.colors[i].name) {
                              found = true;
                              break;
                            }
                          }
                          if (!found) {
                            context.read<ProductFormBloc>().add(RemoveProductColor(i));
                            break;
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
          
                  // Product fields (name, code, description, price)
                  ProductInfoForm(
                    nameController: nameController,
                    codeController: codeController,
                    descriptionController: descriptionController,
                    // priceController: priceController,
                    // codeReadOnly: state.isEditing,
                  ),
                  const SizedBox(height: 20),

                  // Color selector
                  const Text(
                    "Colores disponibles",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 20),
          
                  // Tags section
                  const Text(
                    "Etiquetas",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  LabelPicker(
                    tags: state.tags,
                    onTagsChanged: (newTags) {
                      // Si hay más tags, se añadió uno
                      if (newTags.length > state.tags.length) {
                        final newTag = newTags.last;
                        context.read<ProductFormBloc>().add(AddProductTag(newTag));
                      }
                      // Si hay menos tags, se eliminó uno
                      else if (newTags.length < state.tags.length) {
                        // Encontrar qué tag falta
                        for (int i = 0; i < state.tags.length; i++) {
                          if (!newTags.contains(state.tags[i])) {
                            context.read<ProductFormBloc>().add(RemoveProductTag(i));
                            break;
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
          
                  // Variants section
                  const Text(
                    "Variantes",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  VariantsEditor(
                    variants: state.variants,
                    onVariantsChanged: () {
                      // widget.onVariantsChanged();
                    },
                    // onVariantAdded: (variant) {
                    //   context.read<ProductFormBloc>().add(AddProductVariant(variant));
                    // },
                    // onVariantRemoved: (index) {
                    //   context.read<ProductFormBloc>().add(RemoveProductVariant(index));
                    // },
                    // onOptionAdded: (variantIndex, option) {
                    //   context.read<ProductFormBloc>().add(AddVariantOption(variantIndex, option));
                    // },
                    // onOptionRemoved: (variantIndex, optionIndex) {
                    //   context.read<ProductFormBloc>().add(RemoveVariantOption(variantIndex, optionIndex));
                    // },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        
        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildButtons(context, state),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, ProductFormLoaded state) {
    return Column(
      children: [
        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validateAndSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              state.isEditing ? ProductStrings.save : "Crear Producto",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        
        // Delete button - only show when editing
        if (state.isEditing) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.red),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                ProductStrings.delete,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _validateAndSave() {
    // Validaciones básicas
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del producto es requerido')),
      );
      return;
    }

    if (codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código del producto es requerido')),
      );
      return;
    }

    // Validar precio
    double? price;
    try {
      price = double.parse(priceController.text);
      if (price <= 0) {
        throw FormatException('El precio debe ser mayor a cero');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un precio válido')),
      );
      return;
    }

    // Obtenemos el estado actual para usar sus datos
    final currentState = context.read<ProductFormBloc>().state;
    if (currentState is ProductFormLoaded) {
      // Enviar evento para guardar el producto
      context.read<ProductFormBloc>().add(SaveProductForm(
        name: nameController.text,
        code: codeController.text,
        description: descriptionController.text,
        price: price,
        imagePath: currentState.imagePath,
        colors: currentState.colors,
        tags: currentState.tags,
        variants: currentState.variants,
      ));
    }
  }

  void _handleDelete() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Está seguro que desea eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Close dialog
              Navigator.pop(context);
              
              // Usar el Bloc para eliminar el producto
              final currentState = context.read<ProductFormBloc>().state;
              if (currentState is ProductFormLoaded) {
                if (currentState.productCode != null) {
                  context.read<ProductFormBloc>().add(
                    DeleteProductForm(currentState.productCode!),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}