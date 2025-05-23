// lib/widgets/write_review_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_event.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/utils/ui/snackbar_manager_web.dart';

import '../../../bloc/product_blocs/products_management/product_bloc.dart';
import '../../../bloc/product_blocs/products_management/product_event.dart';
import '../../../bloc/product_blocs/products_management/product_state.dart';
import '../../../models/product_models/product.dart';
import '../../../services/api_services/review_service/review_service.dart';

class WriteReviewWidget extends StatefulWidget {
  final Product product;
  final int? idReview;
  final double? previousRating;

  const WriteReviewWidget({
    super.key,
    required this.product,
    this.idReview,
    this.previousRating,
  });

  @override
  State<WriteReviewWidget> createState() => _WriteReviewWidgetState();
}

class _WriteReviewWidgetState extends State<WriteReviewWidget> {
  final TextEditingController _reviewController = TextEditingController();
  static const int maxReviewLength = 250;
  bool _isSubmitting = false;
  late double _selectedRating;

  @override
  void initState() {
    super.initState();
    // Initialize rating from previous or zero
    _selectedRating = widget.previousRating ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (_isSubmitting && state is ProductLoaded) {
          setState(() {
            _isSubmitting = false;
            _reviewController.clear();
            _selectedRating = 0.0;
          });

          SnackbarManager.showSuccess(
            context, 
            message: 'Gracias por tu reseña.'
          );

          if (widget.idReview != null) {
            Navigator.of(context).pop();
          }
        }
      },
      child: SizedBox(
        height: widget.idReview == null
            ? null
            : MediaQuery.of(context).size.height * 0.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escribe una reseña',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      i <= _selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() => _selectedRating = i.toDouble());
                    },
                  ),
                const SizedBox(width: 8),
                Text(
                  '$_selectedRating/5',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: null,
              maxLength: maxReviewLength,
              decoration: InputDecoration(
                hintText: 'Comparte tu experiencia con este producto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _isSubmitting
                  ? const SizedBox.shrink()
                  : ElevatedButton(
                      onPressed: () async {
                        final userId =
                            context.read<UsersBloc>().state.sessionUser!.id;
                        final text = _reviewController.text.trim();
                        if (text.isEmpty || _selectedRating == 0.0) {
                          SnackbarManager.showWarning(
                            context, 
                            message: 'Por favor ingresa una reseña y calificación.'
                          );
                          return;
                        }
                        setState(() => _isSubmitting = true);

                        if (widget.idReview == null) {
                          final created = await ReviewService.createReview(
                            productCode: widget.product.code,
                            idUser: userId,
                            calification: _selectedRating,
                            commentary: text,
                          );
                          if (created != null) {
                            context.read<ProductBloc>().add(LoadProducts());
                          } else {
                            setState(() => _isSubmitting = false);
                            SnackbarManager.showError(
                              context, 
                              message: 'Error al enviar la reseña.'
                            );
                          }
                        } else {
                          final updated = await ReviewService.updateReview(
                            idReview: widget.idReview!,
                            calification: _selectedRating,
                            commentary: text,
                          );
                          if (updated != null) {
                            context.read<ProductBloc>().add(LoadProducts());
                            context.read<ProductDetailsBloc>().add(LoadProductDetails(widget.product.code));
                          } else {
                            setState(() => _isSubmitting = false);
                            SnackbarManager.showError(
                              context, 
                              message: 'Error al actualizar la reseña.'
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Enviar Reseña',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
