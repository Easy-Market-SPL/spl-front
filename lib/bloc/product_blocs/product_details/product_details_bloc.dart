import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_state.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/products_strings.dart';

import '../../../services/api_services/product_services/product_service.dart';
import 'product_details_event.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
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
      final variants =
          await ProductService.getProductVariants(event.productCode);
      final labels = product.labels ?? [];

      if (SPLVariables.isRated) {
        await product.fetchReviewsProduct(product.code);
        await product.fetchReviewAverage(product.code);
      }

      emit(ProductDetailsLoaded(
        product: product,
        colors: colors ?? [],
        variants: variants ?? [],
        labels: labels,
      ));
    } catch (e) {
      debugPrint('Error loading product details: $e');
      emit(ProductDetailsError(ProductStrings.productLoadError));
    }
  }

  void _onClearProductDetails(
      ClearProductDetails event, Emitter<ProductDetailsState> emit) {
    emit(ProductDetailsInitial());
  }
}
