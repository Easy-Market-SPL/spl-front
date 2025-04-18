import 'package:flutter/material.dart';
import 'package:spl_front/models/order_models/order_model.dart';
import 'package:spl_front/models/order_models/order_product.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/utils/ui/format_currency.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

class ProductPopup extends StatefulWidget {
  final OrderModel orderModel;
  const ProductPopup({super.key, required this.orderModel});

  @override
  State<ProductPopup> createState() => _ProductPopupState();
}

class _ProductPopupState extends State<ProductPopup> {
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    // ⇣ cargamos una sola vez todos los productos de la orden
    _loadFuture = widget.orderModel.fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: SizedBox(
                  child: CustomLoading(),
                ),
              );
            }

            final items = widget.orderModel.orderProducts;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(context),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (_, i) => _line(items[i]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ───────────────────────── cabecera ──────────────────────────
  Widget _header(BuildContext ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 8, 12),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                OrderStrings.productsInOrder,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              splashRadius: 22,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            )
          ],
        ),
      );

  // ────────────────────── línea de producto ─────────────────────
  Widget _line(OrderProduct op) {
    final p = op.product!;
    final subtotal = p.price * op.quantity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _thumb(p.imagePath),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  p.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 12),
              ]),
              Row(
                children: [
                  Text(formatCurrency(p.price),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'x${op.quantity}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatCurrency(subtotal),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                ],
              ),
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ───────────── imagen con placeholder fijo ─────────────
  Widget _thumb(String url) {
    const double size = 64;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(Icons.image, size: 26, color: Colors.white70),
          ),
          if (url.isNotEmpty)
            Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              loadingBuilder: (_, widget, progress) =>
                  progress == null ? widget : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
