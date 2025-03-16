import 'package:flutter/material.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/data/variant.dart';
import 'package:spl_front/models/data/variant_option.dart';
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

  /// Track the product's tags here.
  List<String> _tags = [];
  /// Track all variants here
  List<Variant> _variants = [];
  List<ProductColor> _colors = [];

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.product != null) {
      // Editing existing product - initialize with product data
      nameController = TextEditingController(text: widget.product!.name);
      codeController = TextEditingController(text: widget.product!.code);
      descriptionController = TextEditingController(text: widget.product!.description);
      
      // For demo, we'll use placeholder data
      // In a real app, you would load these from the product object
      _tags = ['Etiqueta 1', 'Etiqueta 2'];
      _variants = [
        Variant(name: 'Variante 1', options: [
          VariantOption(name: 'Opción 1'),
          VariantOption(name: 'Opción 2'),
        ]),
      ];
      _colors = [
        ProductColor(idColor: 0, name: 'Rojo', hexCode: '#F44336'),
        ProductColor(idColor: 0, name: 'Verde', hexCode: '#4CAF50'),
      ];
    } else {
      // Creating new product - initialize with empty values
      nameController = TextEditingController();
      codeController = TextEditingController();
      descriptionController = TextEditingController();
      
      // Start with empty arrays or default values
      _tags = [];
      _variants = [];
      _colors = [];
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BusinessUserBackAppBar(
        hintText: BusinessStrings.searchHint,
        onFilterPressed: () {
          // TODO: Implement filters action
        },
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Title bar (shows "Edit Product" or "Create Product")
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              widget.isEditing ? "Editar Producto" : "Crear Producto",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Scrollable content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Picker
                    const ProductImagePickerWidget(),
                    const SizedBox(height: 4),
            
                    // Color selector
                    ColorPickerWidget(
                      initialColors: _colors,
                      onColorsChanged: (newColors) {
                        setState(() {
                          _colors = newColors;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
            
                    // Product fields (name, code, description)
                    ProductInfoForm(
                      nameController: nameController,
                      codeController: codeController,
                      descriptionController: descriptionController,
                    ),
                    const SizedBox(height: 20),
            
                    // Tags section
                    LabelPicker(
                      tags: _tags,
                      onTagsChanged: (newTags) {
                        setState(() {
                          _tags = newTags;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
            
                    // Variants section
                    VariantsEditor(
                      variants: _variants,
                      onVariantsChanged: () {
                        // Notify changes or perform additional logic
                      },
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
            child: _buildButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.isEditing ? ProductStrings.save : "Crear Producto",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        
        // Delete button - only show when editing
        if (widget.isEditing) ...[
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

  void _handleSave() {
    // Validate required fields
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

    // Create product data object from form inputs
    final productData = {
      'name': nameController.text,
      'code': codeController.text,
      'description': descriptionController.text,
      'colors': _colors,
      'tags': _tags,
      'variants': _variants,
      // Add other fields as needed
    };

    if (widget.isEditing) {
      // TODO: Call update API
      debugPrint('Updating product: $productData');
    } else {
      // TODO: Call create API
      debugPrint('Creating product: $productData');
    }

    // Return to previous screen
    Navigator.pop(context);
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
              
              // TODO: Call delete API
              debugPrint('Deleting product: ${widget.product?.code}');
              
              // Return to previous screen
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}