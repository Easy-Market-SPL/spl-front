import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_filter/product_filter_event.dart';
import 'package:spl_front/bloc/product_blocs/product_filter/product_filter_state.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';

import '../products_management/product_bloc.dart';
import '../products_management/product_event.dart';

class ProductFilterBloc extends Bloc<ProductFilterEvent, ProductFilterState> {
  final ProductBloc productBloc;

  ProductFilterBloc({required this.productBloc}) : super(InitialFilterState()) {
    on<InitFilters>(_onInitFilters);
    on<ApplyFiltersFromDialog>(_onApplyFiltersFromDialog);
    on<RemoveFilter>(_onRemoveFilter);
    on<ClearFilters>(_onClearFilters);
    on<SetSearchQuery>(_onSetSearchQuery);
    on<ChangeLabelFilter>(_onChangeLabelFilter);
  }

  void _onInitFilters(InitFilters event, Emitter<ProductFilterState> emit) {
    emit(ProductFilterState(
      minPrice: null,
      maxPrice: null,
      minRating: null,
      selectedLabels: null,
      searchQuery: null,
      activeLabel: DashboardStrings.allLabels,
    ));
  }

  void _onApplyFiltersFromDialog(
      ApplyFiltersFromDialog event, Emitter<ProductFilterState> emit) {
    final newState = state.copyWith(
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      minRating: event.minRating,
      selectedLabels: event.selectedLabels,
    );

    emit(newState);

    _applyFiltersToProducts();
  }

  void _onRemoveFilter(RemoveFilter event, Emitter<ProductFilterState> emit) {
    late ProductFilterState newState;

    switch (event.filterType) {
      case ProductFilterType.minPrice:
        newState = state.copyWith(minPrice: null);
        break;
      case ProductFilterType.maxPrice:
        newState = state.copyWith(maxPrice: null);
        break;
      case ProductFilterType.minRating:
        newState = state.copyWith(minRating: null);
        break;
    }

    emit(newState);

    _applyFiltersToProducts();
  }

  void _onClearFilters(ClearFilters event, Emitter<ProductFilterState> emit) {
    final newState = state.copyWith(
      minPrice: null,
      maxPrice: null,
      minRating: null,
      selectedLabels: null,
    );

    emit(newState);

    _applyFiltersToProducts();
  }

  void _onSetSearchQuery(
      SetSearchQuery event, Emitter<ProductFilterState> emit) {
    final query = event.query.isEmpty ? null : event.query;
    final newState = state.copyWith(searchQuery: query);

    emit(newState);

    _applyFiltersToProducts();
  }

  void _onChangeLabelFilter(
      ChangeLabelFilter event, Emitter<ProductFilterState> emit) {
    final newState = state.copyWith(activeLabel: event.labelName);
    emit(newState);

    productBloc.add(FilterProductsByCategory(event.labelName));
  }

  void _applyFiltersToProducts() {
    productBloc.add(
      FilterProducts(
        searchQuery: state.searchQuery,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        minRating: state.minRating,
        selectedLabels: state.selectedLabels,
      ),
    );
  }
}
