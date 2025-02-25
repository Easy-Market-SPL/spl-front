import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class AddItem extends CartEvent {
  final Map<String, dynamic> item;

  const AddItem(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveItem extends CartEvent {
  final Map<String, dynamic> item;

  const RemoveItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateItemQuantity extends CartEvent {
  final Map<String, dynamic> item;
  final int quantity;

  const UpdateItemQuantity(this.item, this.quantity);

  @override
  List<Object> get props => [item, quantity];
}

class ClearCart extends CartEvent {}