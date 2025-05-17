import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_event.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_state.dart';
import 'package:spl_front/models/product_models/reviews/review_average.dart';
import 'package:spl_front/services/api_services/review_service/review_service.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

import '../../../models/product_models/product.dart';
import '../../../services/api_services/product_services/product_service.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<FilterProducts>(_onFilterProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<RemoveReview>(_onRemoveReview);
  }

  Future<List<Product>?> _loadProducts() async {
    await ProductService.initializeProductService();
    final products = await ProductService.getProducts();

    if (SPLVariables.isRated && products != null) {
      await getProductsWithRatings(products);
    }

    return products;
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _loadProducts();

      if (products == null) {
        emit(ProductError(ProductStrings.productLoadingError));
      } else {
        emit(ProductLoaded(products));
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
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
          // No need to filter, just change category
          emit(ProductLoaded(products ?? [], activeCategory: event.category));
          return;
        }

        final List<Product> filteredProducts = products
                ?.where((Product product) =>
                    product.labels
                        ?.any((category) => category.name == event.category) ??
                    false)
                .toList() ??
            [];

        emit(ProductLoaded(filteredProducts, activeCategory: event.category));
      } catch (e) {
        debugPrint('e');
        emit(ProductError(e.toString()));
      }
    }
  }

  Future<void> _onFilterProducts(
      FilterProducts event, Emitter<ProductState> emit) async {
    try {
      emit(ProductLoading());
      final products = await _loadProducts();

      if (products == null || products.isEmpty) {
        emit(ProductError(ProductStrings.productLoadingError));
        return;
      }

      List<Product> filteredProducts = List.from(products);

      // Search by name or description
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final query = event.searchQuery!.toLowerCase();
        filteredProducts = filteredProducts
            .where((product) =>
                product.name.toLowerCase().contains(query) ||
                (product.description.toLowerCase().contains(query)))
            .toList();
      }

      // Apply price filters
      if (event.minPrice != null || event.maxPrice != null) {
        filteredProducts = filteredProducts.where((product) {
          final price = product.price;
          final minOk = event.minPrice == null || price >= event.minPrice!;
          final maxOk = event.maxPrice == null || price <= event.maxPrice!;
          return minOk && maxOk;
        }).toList();
      }

      // Apply rating filter
      if (event.minRating != null && event.minRating! > 0) {
        filteredProducts = filteredProducts
            .where((product) => (product.rating ?? 0) >= event.minRating!)
            .toList();
      }

      // Apply label filters
      if (event.selectedLabels != null && event.selectedLabels!.isNotEmpty) {
        filteredProducts = filteredProducts.where((product) {
          if (product.labels == null || product.labels!.isEmpty) {
            return false;
          }

          return product.labels!.any((productLabel) => event.selectedLabels!
              .any((selectedLabel) =>
                  productLabel.idLabel == selectedLabel.idLabel));
        }).toList();
      }

      emit(ProductLoaded(filteredProducts));
    } catch (e) {
      debugPrint(e.toString());
      emit(ProductError(e.toString()));
    }
  }

  // Handle refreshing products
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

  Future<void> _onRemoveReview(
      RemoveReview event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final curr = state as ProductLoaded;
      final updatedProducts = curr.products.map((p) {
        if (p.code == event.productCode) {
          final newReviews =
              p.reviews?.where((r) => r.id != event.reviewId).toList() ?? [];
          return p.copyWith(reviews: newReviews);
        }
        return p;
      }).toList();
      emit(ProductLoaded(updatedProducts, activeCategory: curr.activeCategory));
    }
  }

  Future<void> getProductsWithRatings(List<Product> products) async {
    await ReviewService.initializeReviewService();
    List<ReviewAverage> reviewAverages = await ReviewService.getAllReviewAverages() ?? [];

    for (var product in products) {
      final reviewAverage = reviewAverages.firstWhere(
        (review) => review.productId == product.code,
        orElse: () => ReviewAverage(productId: product.code, average: 0),
      );
      product.rating = reviewAverage.average;
    }
  }
}
