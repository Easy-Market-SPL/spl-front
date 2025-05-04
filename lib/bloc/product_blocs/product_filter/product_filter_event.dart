import 'package:equatable/equatable.dart';

import '../../../models/product_models/labels/label.dart';

enum ProductFilterType { minPrice, maxPrice, minRating }

abstract class ProductFilterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitFilters extends ProductFilterEvent {}

class ApplyFiltersFromDialog extends ProductFilterEvent {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<Label>? selectedLabels;

  ApplyFiltersFromDialog({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.selectedLabels,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice, minRating, selectedLabels];
}

class RemoveFilter extends ProductFilterEvent {
  final ProductFilterType filterType;

  RemoveFilter(this.filterType);

  @override
  List<Object> get props => [filterType];
}

class ClearFilters extends ProductFilterEvent {}

class SetSearchQuery extends ProductFilterEvent {
  final String query;

  SetSearchQuery(this.query);

  @override
  List<Object> get props => [query];
}

class ChangeLabelFilter extends ProductFilterEvent {
  final String labelName;

  ChangeLabelFilter(this.labelName);

  @override
  List<Object> get props => [labelName];
}
