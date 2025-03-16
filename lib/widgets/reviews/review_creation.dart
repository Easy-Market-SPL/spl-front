import 'package:flutter/material.dart';

class WriteReviewWidget extends StatefulWidget {
  const WriteReviewWidget({super.key});

  @override
  State<WriteReviewWidget> createState() => _WriteReviewWidgetState();
}

class _WriteReviewWidgetState extends State<WriteReviewWidget> {
  final TextEditingController _reviewController = TextEditingController();
  final maxReviewLength = 250;
  double _selectedRating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Escribe una reseña", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Star rating row
        Row(
          children: [
            for (int i = 1; i <= 5; i++)
              IconButton(
                icon: Icon(
                  i <= _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _selectedRating = i.toDouble();
                  });
                },
              ),
            const SizedBox(width: 8),
            Text("$_selectedRating/5", style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        // TextField for review
        TextField(
          controller: _reviewController,
          maxLines: null,
          maxLength: maxReviewLength,
          decoration: InputDecoration(
            hintText: "Comparte tu experiencia con este producto",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Submit review logic
              final text = _reviewController.text.trim();
              if (text.isNotEmpty && _selectedRating > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gracias por tu reseña con $_selectedRating estrellas")),
                );
                // Clear fields
                setState(() {
                  _reviewController.clear();
                  _selectedRating = 0.0;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor ingresa una reseña y calificación.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Enviar Reseña", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
