import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_event.dart';
import 'package:spl_front/bloc/ui_management/product/products/product_state.dart';
import 'package:spl_front/services/api/product_service.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<RefreshProducts>(_onRefreshProducts);
  }

  // Handle loading products
  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await ProductService.initializeProductService();

      final products = await ProductService.getProducts();

      if (products == null || products.isEmpty) {
        emit(ProductError(ProductStrings.productLoadingError));
      } else {
        emit(ProductLoaded(products));
      }
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      emit(ProductError(e.toString()));
    }
  }

  // Handle filtering products by category
  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event, 
    Emitter<ProductState> emit
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      
      if (event.category == "Todos") {
        // No need to reload, just change category
        emit(ProductLoaded(currentState.products, activeCategory: event.category));
        return;
      }
      
      try {
        emit(ProductLoading());
        final products = await ProductService.getProducts();
        final filteredProducts = products?.where(
          (product) => product.code.isNotEmpty
        ).toList() ?? [];
        
        emit(ProductLoaded(filteredProducts, activeCategory: event.category));
      } catch (e) {
        debugPrint(e.toString());
        emit(ProductError(e.toString()));
      }
    }
  }

  // Handle refreshing products
  Future<void> _onRefreshProducts(RefreshProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(ProductLoading());
      try {
        final products = await ProductService.getProducts();
        if (products != null) {
          emit(ProductLoaded(products, activeCategory: currentState.activeCategory));
        } else {
          emit(ProductLoaded([], activeCategory: currentState.activeCategory));
        }
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    } else {
      add(LoadProducts());
    }
  }
}