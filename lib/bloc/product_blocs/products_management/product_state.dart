import 'package:equatable/equatable.dart';

import '../../../models/product_models/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final String activeCategory;

  const ProductLoaded(this.products, {this.activeCategory = "Todos"});

  @override
  List<Object?> get props => [products, activeCategory];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
