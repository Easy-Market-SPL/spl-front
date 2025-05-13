import 'package:equatable/equatable.dart';

abstract class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductDetails extends ProductDetailsEvent {
  final String productCode;
  
  const LoadProductDetails(this.productCode);
}

class ClearProductDetails extends ProductDetailsEvent {}