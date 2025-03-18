import 'package:equatable/equatable.dart';
import 'package:spl_front/models/data/product.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/models/data/variant.dart';

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
  final List<String> tags;
  final List<Variant> variants;
  final bool isEditing;
  
  const ProductFormLoaded({
    this.productCode,
    this.name = '',
    this.code = '',
    this.description = '',
    this.price = 0.0,
    this.imagePath,
    this.colors = const [],
    this.tags = const [],
    this.variants = const [],
    this.isEditing = false,
  });
  
  ProductFormLoaded copyWith({
    String? name,
    String? code,
    String? description,
    double? price,
    String? imagePath,
    List<ProductColor>? colors,
    List<String>? tags,
    List<Variant>? variants,
  }) {
    return ProductFormLoaded(
      productCode: productCode,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      colors: colors ?? this.colors,
      tags: tags ?? this.tags,
      variants: variants ?? this.variants,
      isEditing: isEditing,
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
    tags, 
    variants,
    isEditing,
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