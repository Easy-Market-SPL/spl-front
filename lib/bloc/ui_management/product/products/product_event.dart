import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/label.dart';

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