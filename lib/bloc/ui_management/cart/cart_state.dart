import 'package:equatable/equatable.dart';

class CartState extends Equatable {
  final List<Map<String, dynamic>> items;
  final bool isLoading;

  const CartState({this.items = const [], this.isLoading = false});

  CartState copyWith({List<Map<String, dynamic>>? items, bool? isLoading}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [items, isLoading];
}