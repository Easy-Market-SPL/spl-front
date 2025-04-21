// lib/bloc/ui_management/product/products/product_bloc.dart
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

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await ProductService.initializeProductService();
      final products = await ProductService.getProducts();

      if (products == null || products.isEmpty) {
        emit(ProductError(ProductStrings.productLoadingError));
      } else {
        // Cargar reseñas y promedio para cada producto
        for (final product in products) {
          await product.fetchReviewsProduct(product.code);
          await product.fetchReviewAverage(product.code);
        }
        emit(ProductLoaded(products));
      }
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFilterProductsByCategory(
      FilterProductsByCategory event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      try {
        emit(ProductLoading());
        final products = await ProductService.getProducts();
        if (event.category == "Todos") {
          emit(ProductLoaded(products ?? [], activeCategory: event.category));
          return;
        }
        final filtered = products
                ?.where((p) =>
                    p.labels?.any((lbl) => lbl.name == event.category) ?? false)
                .toList() ??
            [];
        emit(ProductLoaded(filtered, activeCategory: event.category));
      } catch (e) {
        debugPrint('❌ $e');
        emit(ProductError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshProducts(
      RefreshProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final curr = state as ProductLoaded;
      emit(ProductLoading());
      try {
        final products = await ProductService.getProducts();
        emit(ProductLoaded(
          products ?? [],
          activeCategory: curr.activeCategory,
        ));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    } else {
      add(LoadProducts());
    }
  }
}
