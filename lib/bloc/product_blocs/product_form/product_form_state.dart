import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:spl_front/models/product_models/variants/variant.dart';

import '../../../models/product_models/labels/label.dart';
import '../../../models/product_models/product.dart';
import '../../../models/product_models/product_color.dart';

abstract class ProductFormState extends Equatable {
  const ProductFormState();

  @override
  List<Object?> get props => [];
}

class ProductFormInitial extends ProductFormState {}

class ProductFormLoading extends ProductFormState {}

class ProductFormLoaded extends ProductFormState {
  final String? productCode;
  final String name;
  final String code;
  final String description;
  final double price;
  final String? imagePath;
  final List<ProductColor> colors;
  final List<Label> labels;
  final List<Variant> variants;
  final bool isEditing;
  final Uint8List? webImageBytes;

  const ProductFormLoaded({
    this.productCode,
    this.name = '',
    this.code = '',
    this.description = '',
    this.price = 0.0,
    this.imagePath,
    this.colors = const [],
    this.labels = const [],
    this.variants = const [],
    this.isEditing = false,
    this.webImageBytes,
  });

  ProductFormLoaded copyWith({
    String? name,
    String? code,
    String? description,
    double? price,
    String? imagePath,
    List<ProductColor>? colors,
    List<Label>? labels,
    List<Variant>? variants,
    Uint8List? webImageBytes,
  }) {
    return ProductFormLoaded(
      productCode: productCode,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      colors: colors ?? this.colors,
      labels: labels ?? this.labels,
      variants: variants ?? this.variants,
      isEditing: isEditing,
      webImageBytes: webImageBytes ?? this.webImageBytes,
    );
  }

  @override
  List<Object?> get props => [
        productCode,
        name,
        code,
        description,
        price,
        imagePath,
        colors,
        labels,
        variants,
        isEditing,
        webImageBytes,
      ];
}

class ProductFormSaving extends ProductFormState {}

class ProductFormSuccess extends ProductFormState {
  final String message;
  final Product? product;

  const ProductFormSuccess(this.message, {this.product});

  @override
  List<Object?> get props => [message, product];
}

class ProductFormError extends ProductFormState {
  final String error;

  const ProductFormError(this.error);

  @override
  List<Object?> get props => [error];
}

class ProductFormDeleted extends ProductFormState {
  final String message;

  const ProductFormDeleted(this.message);

  @override
  List<Object?> get props => [message];
}
