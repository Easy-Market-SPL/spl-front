import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_state.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/data/variant.dart';
import 'package:spl_front/models/data/variant_option.dart';
import 'package:spl_front/services/api/product_service.dart';
import 'package:spl_front/services/supabase/storage/storage_service.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  ProductFormBloc() : super(ProductFormInitial()) {
    on<InitProductForm>(_onInitProductForm);
    on<SaveProductForm>(_onSaveProductForm);
    on<DeleteProductForm>(_onDeleteProductForm);
    on<UpdateProductImage>(_onUpdateProductImage);
    on<AddProductColor>(_onAddProductColor);
    on<RemoveProductColor>(_onRemoveProductColor);
    on<AddProductTag>(_onAddProductTag);
    on<RemoveProductTag>(_onRemoveProductTag);
    on<AddProductVariant>(_onAddProductVariant);
    on<RemoveProductVariant>(_onRemoveProductVariant);
    on<AddVariantOption>(_onAddVariantOption);
    on<RemoveVariantOption>(_onRemoveVariantOption);
  }

  // Handle form initialization
  Future<void> _onInitProductForm(
    InitProductForm event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormLoading());
    try {
      if (event.productCode != null) {
        final product = await ProductService.getProduct(event.productCode!);
        if (product != null) {
          // In a real case, you would load colors, variants, and tags from the product
          // For now, we use test data
          emit(ProductFormLoaded(
            productCode: product.code,
            name: product.name,
            code: product.code,
            description: product.description,
            price: double.tryParse(product.price.toString()) ?? 0.0,
            imagePath: product.imagePath,
            colors: [
              ProductColor(idColor: 1, name: 'Rojo', hexCode: '#F44336'),
              ProductColor(idColor: 2, name: 'Verde', hexCode: '#4CAF50'),
            ],
            tags: ['Etiqueta 1', 'Etiqueta 2'],
            variants: [
              Variant(name: 'Talla', options: [
                VariantOption(name: 'S'),
                VariantOption(name: 'M'),
                VariantOption(name: 'L'),
              ]),
            ],
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
    final imageChanged = StorageService.isLocalImage(event.imagePath);
    emit(ProductFormSaving());
    try {
      String? imageUrl = event.imagePath;
      if (imageChanged) {
        imageUrl = await StorageService().uploadImage(event.imagePath!, event.code);
        if (imageUrl == null) {
          emit(ProductFormError(ProductStrings.productImageUploadError));
          return;
        }
      }

      final product = Product(
        code: event.code,
        name: event.name,
        description: event.description,
        price: event.price,
        imagePath: imageUrl ?? '',
      );

      // Update product
      if (previousState is ProductFormLoaded && previousState.isEditing) {
        final updatedProduct = await ProductService.updateProduct(product);
        if (updatedProduct != null) {
          emit(ProductFormSuccess(ProductStrings.productSaved, product: updatedProduct));
        } else {
          emit(ProductFormError(ProductStrings.productUpdateError));
        }
      } 
      
      // Create product
      else {
        final newProduct = await ProductService.createProduct(product);
        if (newProduct != null) {
          emit(ProductFormSuccess(ProductStrings.productSaved, product: newProduct));
        } else {
          emit(ProductFormError(ProductStrings.productCreateError));
        }
      }
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

  // Handle adding a product color
  void _onAddProductColor(
    AddProductColor event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      emit(currentState.copyWith(
        colors: List.from(currentState.colors)..add(event.color),
      ));
    }
  }

  // Handle removing a product color
  void _onRemoveProductColor(
    RemoveProductColor event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      final colors = List<ProductColor>.from(currentState.colors);
      if (event.colorIndex >= 0 && event.colorIndex < colors.length) {
        colors.removeAt(event.colorIndex);
        emit(currentState.copyWith(colors: colors));
      }
    }
  }

  // Handle adding a product tag
  void _onAddProductTag(
    AddProductTag event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      emit(currentState.copyWith(
        tags: List.from(currentState.tags)..add(event.tag),
      ));
    }
  }

  // Handle removing a product tag
  void _onRemoveProductTag(
    RemoveProductTag event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      final tags = List<String>.from(currentState.tags);
      if (event.tagIndex >= 0 && event.tagIndex < tags.length) {
        tags.removeAt(event.tagIndex);
        emit(currentState.copyWith(tags: tags));
      }
    }
  }
  
  void _onAddProductVariant(
    AddProductVariant event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      emit(currentState.copyWith(
        variants: List.from(currentState.variants)..add(event.variant),
      ));
    }
  }
  
  void _onRemoveProductVariant(
    RemoveProductVariant event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      final variants = List<Variant>.from(currentState.variants);
      if (event.variantIndex >= 0 && event.variantIndex < variants.length) {
        variants.removeAt(event.variantIndex);
        emit(currentState.copyWith(variants: variants));
      }
    }
  }
  
  void _onAddVariantOption(
    AddVariantOption event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      final variants = List<Variant>.from(currentState.variants);
      if (event.variantIndex >= 0 && event.variantIndex < variants.length) {
        final variant = variants[event.variantIndex];
        final List<VariantOption> options = List.from(variant.options)..add(event.option);
        variants[event.variantIndex] = Variant(
          name: variant.name,
          options: options,
        );
        emit(currentState.copyWith(variants: variants));
      }
    }
  }
  
  void _onRemoveVariantOption(
    RemoveVariantOption event,
    Emitter<ProductFormState> emit,
  ) {
    if (state is ProductFormLoaded) {
      final currentState = state as ProductFormLoaded;
      final variants = List<Variant>.from(currentState.variants);
      if (event.variantIndex >= 0 && event.variantIndex < variants.length) {
        final variant = variants[event.variantIndex];
        if (event.optionIndex >= 0 && event.optionIndex < variant.options.length) {
          final List<VariantOption> options = List.from(variant.options);
          options.removeAt(event.optionIndex);
          variants[event.variantIndex] = Variant(
            name: variant.name,
            options: options,
          );
          emit(currentState.copyWith(variants: variants));
        }
      }
    }
  }
}