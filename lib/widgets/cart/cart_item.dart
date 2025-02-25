import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_bloc.dart';
import 'package:spl_front/bloc/ui_management/cart/cart_event.dart';

class CartItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 14, right: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/empty_background.jpg',
                fit: BoxFit.cover,
                width: 95,
                height: 95,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(item['description'], style: TextStyle(fontSize: 12)),
                        Text('\$${item['price']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIconButton(context, Icons.remove, () {
                            int newQuantity = item['quantity'] - 1;
                            if (newQuantity > 0) {
                              context.read<CartBloc>().add(UpdateItemQuantity(item, newQuantity));
                            }
                          }),
                          Text('${item['quantity']}', style: TextStyle(fontSize: 12)),
                          _buildIconButton(context, Icons.add, () {
                            context.read<CartBloc>().add(UpdateItemQuantity(item, item['quantity'] + 1));
                          }),
                          _buildIconButton(context, Icons.delete, () {
                            context.read<CartBloc>().add(RemoveItem(item));
                          }, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onPressed, {Color color = Colors.grey}) {
    return SizedBox(
      width: 45,
      height: 45,
      child: IconButton(
        icon: Icon(icon, size: 25, color: color),
        padding: EdgeInsets.all(0),
        onPressed: onPressed,
      ),
    );
  }
}