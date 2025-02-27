import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    //TODO: Implement real data load and possibly have the data load when the customer dashboard initializes
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(
      items: [
        {'name': 'Producto 1', 'description': 'Descripción del Producto 1', 'price': 50.0, 'quantity': 1},
        {'name': 'Producto 2', 'description': 'Descripción del Producto 2', 'price': 30.0, 'quantity': 2},
      ],
      isLoading: false,
    ));
  }
  //TODO: Apply CRUD operations to the cart
  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    final updatedItems = List<Map<String, dynamic>>.from(state.items)..add(event.item);
    emit(state.copyWith(items: updatedItems));
  }

  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    final updatedItems = List<Map<String, dynamic>>.from(state.items)..remove(event.item);
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateItemQuantity(UpdateItemQuantity event, Emitter<CartState> emit) {
    final updatedItems = state.items.map((item) {
      if (item == event.item) {
        return {...item, 'quantity': event.quantity};
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(state.copyWith(items: []));
  }
}