import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';

class ProductFilterState extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<Label>? selectedLabels;
  final String? searchQuery;
  final String activeLabel;

  const ProductFilterState({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.selectedLabels,
    this.searchQuery,
    required this.activeLabel,
  });

  bool get hasActiveFilters => 
    minPrice != null || maxPrice != null || (minRating != null && minRating! > 0);

  // Neccesary for nulls on the copyWith method
  ProductFilterState copyWith({
    Object? minPrice = unchanged,
    Object? maxPrice = unchanged,
    Object? minRating = unchanged,
    Object? selectedLabels = unchanged,
    Object? searchQuery = unchanged,
    Object? activeLabel = unchanged,
  }) {
    return ProductFilterState(
      minPrice: minPrice == unchanged ? this.minPrice : minPrice as double?,
      maxPrice: maxPrice == unchanged ? this.maxPrice : maxPrice as double?,
      minRating: minRating == unchanged ? this.minRating : minRating as double?,
      selectedLabels: selectedLabels == unchanged ? this.selectedLabels : selectedLabels as List<Label>?,
      searchQuery: searchQuery == unchanged ? this.searchQuery : searchQuery as String?,
      activeLabel: activeLabel == unchanged ? this.activeLabel : activeLabel as String,
    );
  }

  // This is a constant object used to check if the value has changed in the copyWith method
  static const unchanged = Object();

  @override
  List<Object?> get props => [
    minPrice, 
    maxPrice, 
    minRating, 
    selectedLabels, 
    searchQuery,
    activeLabel,
  ];
}

class InitialFilterState extends ProductFilterState {
  const InitialFilterState() : super(activeLabel: DashboardStrings.allLabels);
}