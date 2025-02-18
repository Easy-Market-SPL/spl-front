import 'package:flutter/material.dart';

class ProductPopup extends StatelessWidget {

  const ProductPopup({super.key});
  

  @override
  Widget build(BuildContext context) {
    final List<Product> products = [
    Product(
      name: 'Nombre del Producto X',
      description: 'Descripción general del Producto',
      price: 50.0,
      quantity: 1,
    ),
    Product(
      name: 'Nombre del Producto X',
      description: 'Descripción general del Producto',
      price: 50.0,
      quantity: 1,
    ),
  ];
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Productos en esta orden',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();  // Cierra el popup
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Lista de productos
            ListView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductRow(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],  // Imagen del producto (usé un contenedor de placeholder)
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${product.name}[${product.quantity}]'),
                Text(product.description, style: TextStyle(color: Colors.grey)),
                Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final int quantity;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });
}
