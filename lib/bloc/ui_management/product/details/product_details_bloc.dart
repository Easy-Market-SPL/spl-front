import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/details/product_details_state.dart';
import 'package:spl_front/services/api/product_service.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

import 'product_details_event.dart';

class ProductDetailsBloc extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  ProductDetailsBloc() : super(ProductDetailsInitial()) {
    on<LoadProductDetails>(_onLoadProductDetails);
    on<ClearProductDetails>(_onClearProductDetails);
  }

  Future<void> _onLoadProductDetails(
      LoadProductDetails event, Emitter<ProductDetailsState> emit) async {
    emit(ProductDetailsLoading());
    try {
      // Load the product and its related data
      final product = await ProductService.getProduct(event.productCode);
      
      if (product == null) {
        emit(ProductDetailsError(ProductStrings.productLoadError));
        return;
      }
      
      // Load related entities
      final colors = await ProductService.getProductColors(event.productCode);
      final variants = await ProductService.getProductVariants(event.productCode);
      final labels = product.labels ?? [];
      
      emit(ProductDetailsLoaded(
        product: product,
        colors: colors ?? [],
        variants: variants ?? [],
        labels: labels,
      ));
    } catch (e) {
      debugPrint('❌ Error loading product details: $e');
      emit(ProductDetailsError(ProductStrings.productLoadError));
    }
  }

  void _onClearProductDetails(
      ClearProductDetails event, Emitter<ProductDetailsState> emit) {
    emit(ProductDetailsInitial());
  }

}