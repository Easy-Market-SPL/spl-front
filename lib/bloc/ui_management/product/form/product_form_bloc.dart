import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_state.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/data/variant.dart';
import 'package:spl_front/models/data/variant_option.dart';
import 'package:spl_front/services/api/product_service.dart';

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
  
  Future<void> _onInitProductForm(
    InitProductForm event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormLoading());
    try {
      if (event.productCode != null) {
        // Cargar producto existente
        final product = await ProductService.getProduct(event.productCode!);
        if (product != null) {
          // En un caso real, cargarías colores, variantes y etiquetas del producto
          // Por ahora, usamos datos de prueba
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
          emit(const ProductFormError('No se pudo cargar el producto'));
        }
      } else {
        // Nuevo producto
        emit(const ProductFormLoaded(isEditing: false));
      }
    } catch (e) {
      debugPrint('Error inicializando form: $e');
      emit(ProductFormLoaded(isEditing: event.productCode != null));
    }
  }
  
  Future<void> _onSaveProductForm(
    SaveProductForm event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormSaving());
    try {
      // Aquí iría la lógica para guardar en la API
      await Future.delayed(const Duration(seconds: 1)); // Simulación
      
      final product = Product(
        code: event.code,
        name: event.name,
        description: event.description,
        price: event.price,
        imagePath: event.imagePath ?? '',
      );
      
      if (state is ProductFormLoaded && (state as ProductFormLoaded).isEditing) {
        // Actualizar producto existente
        // await _productService.updateProduct(product);
        emit(ProductFormSuccess('Producto actualizado correctamente', product: product));
      } else {
        // Crear nuevo producto
        // await _productService.createProduct(product);
        emit(ProductFormSuccess('Producto creado correctamente', product: product));
      }
    } catch (e) {
      debugPrint('Error al guardar: $e');
      emit(ProductFormError('Error al guardar: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeleteProductForm(
    DeleteProductForm event,
    Emitter<ProductFormState> emit,
  ) async {
    emit(ProductFormSaving());
    try {
      // await _productService.deleteProduct(event.productCode);
      await Future.delayed(const Duration(seconds: 1)); // Simulación
      emit(const ProductFormDeleted('Producto eliminado correctamente'));
    } catch (e) {
      debugPrint('Error al eliminar: $e');
      emit(ProductFormError('Error al eliminar: ${e.toString()}'));
    }
  }
  
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