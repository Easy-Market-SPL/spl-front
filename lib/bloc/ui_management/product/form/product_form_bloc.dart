import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_state.dart';
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/data/variant.dart';
import 'package:spl_front/services/api/product_service.dart';
import 'package:spl_front/services/supabase/storage/storage_service.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  List<Label>? _originalLabels;
  List<ProductColor>? _originalColors;
  List<Variant>? _originalVariants;

  ProductFormBloc() : super(ProductFormInitial()) {
    on<InitProductForm>(_onInitProductForm);
    on<SaveProductForm>(_onSaveProductForm);
    on<DeleteProductForm>(_onDeleteProductForm);
    on<UpdateProductImage>(_onUpdateProductImage);
  }

  // Handle form initialization
  Future<void> _onInitProductForm(
    InitProductForm event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormLoading());
    try {
      if (event.productCode != null) {
        // Load existing product
        final product = await ProductService.getProduct(event.productCode!);
        if (product != null) {
          // Load related entities
          final colors = await ProductService.getProductColors(event.productCode!);
          final variants = await ProductService.getProductVariants(event.productCode!);
          // Save originals entities relations
          _originalLabels = List.from(product.labels ?? []);
          _originalColors = List.from(colors ?? []);
          _originalVariants = List.from(variants ?? []);
          // Emit loaded state
          emit(ProductFormLoaded(
            productCode: product.code,
            name: product.name,
            code: product.code,
            description: product.description,
            price: double.tryParse(product.price.toString()) ?? 0.0,
            imagePath: product.imagePath,
            colors: colors ?? [],
            labels: product.labels ?? [],
            variants: variants ?? [],
            isEditing: true,
          ));
        } else {
          emit(const ProductFormError(ProductStrings.productLoadError));
        }
      } else {
        // New product
        emit(const ProductFormLoaded(isEditing: false));
      }
    } catch (e) {
      debugPrint('Error initializing form: $e');
      emit(ProductFormError(ProductStrings.productLoadError));
    }
  }

  // Handle saving a product
  Future<void> _onSaveProductForm(
    SaveProductForm event,
    Emitter<ProductFormState> emit,
  ) async {
    final previousState = state;
    if (previousState is! ProductFormLoaded) {
      emit(ProductFormError(ProductStrings.productSaveError));
      return;
    }

    emit(ProductFormSaving());
    try {
      // Handle image upload if needed
      String? imageUrl = event.imagePath;
      if (StorageService.isLocalImage(imageUrl)) {
        imageUrl = await _uploadProductImage(event.imagePath!, event.code, emit);
        if (imageUrl == null) return; // Error already emitted
      }

      // Create product object
      final product = Product(
        code: event.code,
        name: event.name,
        description: event.description,
        price: event.price,
        imagePath: imageUrl ?? '',
      );

      // Save product (update or create)
      final savedProduct = previousState.isEditing 
          ? await ProductService.updateProduct(product)
          : await ProductService.createProduct(product);

      if (savedProduct == null) {
        emit(ProductFormError(previousState.isEditing 
            ? ProductStrings.productUpdateError 
            : ProductStrings.productCreateError));
        return;
      }

      // Update related entities if needed
      await _updateRelatedEntities(savedProduct, previousState);

      // Emit success
      emit(ProductFormSuccess(ProductStrings.productSaved, product: savedProduct));
    } catch (e) {
      debugPrint('Error saving product: $e');
      emit(ProductFormError(ProductStrings.productSaveError));
    }
  }

  // Handle deleting a product
  Future<void> _onDeleteProductForm(
    DeleteProductForm event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormSaving());
    try {
      bool deleted = await ProductService.deleteProduct(event.productCode);
      if (!deleted) {
        emit(ProductFormError(ProductStrings.productDeleteError));
        return;
      }
      emit(const ProductFormDeleted(ProductStrings.productDeleted));
    } catch (e) {
      debugPrint('Error deleting product: $e');
      emit(ProductFormError(ProductStrings.productDeleteError));
    }
  }

  // Handle updating the product image
  void _onUpdateProductImage(
    UpdateProductImage event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      emit(currentState.copyWith(
        imagePath: event.imagePath,
      ));
    }
  }

  Future<String?> _uploadProductImage(String localPath, String code, Emitter<ProductFormState> emit) async {
    try {
      final imageUrl = await StorageService().uploadImage(localPath, code);
      if (imageUrl == null) {
        emit(ProductFormError(ProductStrings.productImageUploadError));
      }
      return imageUrl;
    } catch (e) {
      emit(ProductFormError(ProductStrings.productImageUploadError));
      return null;
    }
  }

  Future<void> _updateRelatedEntities(Product product, ProductFormLoaded state) async {
    // Handle labels
    final bool labelsChanged = !_areLabelsEqual(_originalLabels ?? [], state.labels);
    if (labelsChanged) {
      await ProductService.updateProductLabels(product.code, state.labels);
    }

    // Hanlde colors
    final bool colorsChanged = !_areColorsEqual(_originalColors ?? [], state.colors);
    if (colorsChanged) {
      await ProductService.updateProductColors(product.code, state.colors);
    }

    // Handle variants
    final bool variantsChanged = !_areVariantsEqual(_originalVariants ?? [], state.variants);
    if (variantsChanged) {
      await ProductService.updateProductVariants(product.code, state.variants);
    }
  }

  // Helper method for label comparison
  bool _areLabelsEqual(List<Label> original, List<Label> current) {
    return _areEntitiesListsEqual(original, current, (label) => label.idLabel);
  }

  // Helper method for color comparison
  bool _areColorsEqual(List<ProductColor> original, List<ProductColor> current) {
    return _areEntitiesListsEqual(original, current, (color) => color.idColor);
  }

  // Helper method for variant comparison
  bool _areVariantsEqual(List<Variant> original, List<Variant> current) {
    return _areEntitiesListsEqual(original, current, (variant) => variant.name);
  }

  bool _areEntitiesListsEqual<T, K extends Comparable>(
    List<T> original, 
    List<T> current, 
    K Function(T item) keySelector
  ) {
    if (original.length != current.length) return false;

    // Sort both lists by the key selector for proper comparison
    final sortedOriginal = List<T>.from(original)
      ..sort((a, b) => keySelector(a).compareTo(keySelector(b)));

    final sortedCurrent = List<T>.from(current)
      ..sort((a, b) => keySelector(a).compareTo(keySelector(b)));

    // Compare each item by the selected key
    for (int i = 0; i < sortedOriginal.length; i++) {
      if (keySelector(sortedOriginal[i]) != keySelector(sortedCurrent[i])) {
        return false;
      }
    }

    return true;
  }
}