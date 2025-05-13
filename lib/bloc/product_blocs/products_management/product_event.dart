import 'package:equatable/equatable.dart';

import '../../../models/product_models/labels/label.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class FilterProductsByCategory extends ProductEvent {
  final String category;

  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class FilterProducts extends ProductEvent {
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<Label>? selectedLabels;

  const FilterProducts({
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.selectedLabels,
  });
}

class RefreshProducts extends ProductEvent {}

class RemoveReview extends ProductEvent {
  final String productCode;
  final int reviewId;
  const RemoveReview(this.productCode, this.reviewId);
}
