import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/data/variant.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsLoaded extends ProductDetailsState {
  final Product product;
  final List<ProductColor> colors;
  final List<Variant> variants;
  final List<Label> labels;

  const ProductDetailsLoaded({
    required this.product,
    required this.colors,
    required this.variants,
    required this.labels,
  });
}

class ProductDetailsError extends ProductDetailsState {
  final String message;

  const ProductDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}