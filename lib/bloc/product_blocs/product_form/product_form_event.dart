import 'package:equatable/equatable.dart';
import 'package:spl_front/models/product_models/variants/variant.dart';
import 'package:spl_front/models/product_models/variants/variant_option.dart';

import '../../../models/product_models/labels/label.dart';
import '../../../models/product_models/product_color.dart';

abstract class ProductFormEvent extends Equatable {
  const ProductFormEvent();

  @override
  List<Object?> get props => [];
}

class InitProductForm extends ProductFormEvent {
  final String? productCode; // Null for new products

  const InitProductForm({this.productCode});

  @override
  List<Object?> get props => [productCode];
}

class SaveProductForm extends ProductFormEvent {
  final String name;
  final String code;
  final String description;
  final double price;
  final String? imagePath;
  final List<ProductColor> colors;
  final List<Label> labels;
  final List<Variant> variants;

  const SaveProductForm({
    required this.name,
    required this.code,
    required this.description,
    required this.price,
    this.imagePath,
    required this.colors,
    required this.labels,
    required this.variants,
  });

  @override
  List<Object?> get props =>
      [name, code, description, price, imagePath, colors, labels, variants];
}

class DeleteProductForm extends ProductFormEvent {
  final String productCode;

  const DeleteProductForm(this.productCode);

  @override
  List<Object?> get props => [productCode];
}

class UpdateProductImage extends ProductFormEvent {
  final String imagePath;

  const UpdateProductImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class AddProductColor extends ProductFormEvent {
  final ProductColor color;

  const AddProductColor(this.color);

  @override
  List<Object?> get props => [color];
}

class RemoveProductColor extends ProductFormEvent {
  final int colorIndex;

  const RemoveProductColor(this.colorIndex);

  @override
  List<Object?> get props => [colorIndex];
}

class AddProductLabel extends ProductFormEvent {
  final Label label;

  const AddProductLabel(this.label);

  @override
  List<Object?> get props => [label];
}

class RemoveProductLabel extends ProductFormEvent {
  final int labelIndex;

  const RemoveProductLabel(this.labelIndex);

  @override
  List<Object?> get props => [labelIndex];
}

class AddProductVariant extends ProductFormEvent {
  final Variant variant;

  const AddProductVariant(this.variant);

  @override
  List<Object?> get props => [variant];
}

class RemoveProductVariant extends ProductFormEvent {
  final int variantIndex;

  const RemoveProductVariant(this.variantIndex);

  @override
  List<Object?> get props => [variantIndex];
}

class AddVariantOption extends ProductFormEvent {
  final int variantIndex;
  final VariantOption option;

  const AddVariantOption(this.variantIndex, this.option);

  @override
  List<Object?> get props => [variantIndex, option];
}

class RemoveVariantOption extends ProductFormEvent {
  final int variantIndex;
  final int optionIndex;

  const RemoveVariantOption(this.variantIndex, this.optionIndex);

  @override
  List<Object?> get props => [variantIndex, optionIndex];
}
