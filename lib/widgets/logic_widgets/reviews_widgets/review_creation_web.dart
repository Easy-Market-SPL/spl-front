import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_bloc.dart';
import 'package:spl_front/bloc/product_blocs/product_details/product_details_event.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_bloc.dart';
import 'package:spl_front/bloc/product_blocs/products_management/product_event.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/product_models/product.dart';
import 'package:spl_front/services/api_services/review_service/review_service.dart';
import 'package:spl_front/utils/ui/snackbar_manager_web.dart';

class CompactReviewForm extends StatefulWidget {
  final Product product;

  const CompactReviewForm({
    super.key,
    required this.product,
  });

  @override
  State<CompactReviewForm> createState() => _CompactReviewFormState();
}

class _CompactReviewFormState extends State<CompactReviewForm> {
  final TextEditingController _reviewController = TextEditingController();
  static const int maxReviewLength = 250;
  bool _isSubmitting = false;
  double _selectedRating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and star rating in the same row
            Row(
              children: [
                const Text(
                  'Califica este producto',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Compact star rating
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 1; i <= 5; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedRating = i.toDouble());
                        },
                        child: Icon(
                          i <= _selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      '$_selectedRating/5',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Review field with limited height
            TextField(
              controller: _reviewController,
              maxLines: 2,
              maxLength: maxReviewLength,
              style: const TextStyle(fontSize: 14,),
              decoration: InputDecoration(
                hintText: 'Comparte tu experiencia con este producto',
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            // Submit button 
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text(
                          'Enviar',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _submitReview() async {
    final userId = context.read<UsersBloc>().state.sessionUser!.id;
    final text = _reviewController.text.trim();
    
    if (text.isEmpty || _selectedRating == 0.0) {
      SnackbarManager.showError(
        context, 
        message: 'Por favor ingresa una reseña y calificación.'
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    final created = await ReviewService.createReview(
      productCode: widget.product.code,
      idUser: userId,
      calification: _selectedRating,
      commentary: text,
    );
    
    if (created != null) {
      context.read<ProductBloc>().add(LoadProducts());
      context.read<ProductDetailsBloc>().add(LoadProductDetails(widget.product.code));
      _reviewController.clear();
      setState(() {
        _selectedRating = 0.0;
        _isSubmitting = false;
      });
      SnackbarManager.showSuccess(context, message: 'Reseña enviada. ¡Gracias!');
    } else {
      setState(() => _isSubmitting = false);
      SnackbarManager.showError(context, message: 'Error al enviar la reseña.');
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}