import 'package:equatable/equatable.dart';

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

class RefreshProducts extends ProductEvent {}

class RemoveReview extends ProductEvent {
  final String productCode;
  final int reviewId;
  const RemoveReview(this.productCode, this.reviewId);
}
