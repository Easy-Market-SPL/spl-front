import '../../services/api_services/product_services/product_service.dart';
import '../product_models/product.dart';

class OrderProduct {
  final int idOrder;
  final String idProduct;
  final int quantity;
  double? price;

  Product? product;
  bool isLoading = false;

  OrderProduct({
    required this.idOrder,
    required this.idProduct,
    required this.quantity,
    this.price,
    this.product,
  });

  // Fetch product asynchronously and update loading state
  Future<void> fetchProduct() async {
    isLoading = true;
    product = await ProductService.getProduct(idProduct);
    isLoading = false;
  }

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      idOrder: json["idOrder"],
      idProduct: json["idProduct"] ?? "",
      quantity: json["quantity"],
      price: (json["price"] == null) ? null : json["price"].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "idOrder": idOrder,
        "idProduct": idProduct,
        "quantity": quantity,
        "price": price,
      };
}
