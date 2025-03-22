import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/product_form_event.dart';
import 'package:spl_front/models/data/product_color.dart';
import 'package:spl_front/widgets/products/view/color/product_colors.dart';

class ProductEditColorsSection extends StatelessWidget {
  final List<ProductColor> colors;

  const ProductEditColorsSection({
    super.key,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColorPickerWidget(
          initialColors: colors,
          onColorsChanged: (newColors) {
            _handleColorChanges(context, newColors);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _handleColorChanges(BuildContext context, List<ProductColor> newColors) {
    // Si hay más colores, se añadió uno
    if (newColors.length > colors.length) {
      final newColor = newColors.last;
      context.read<ProductFormBloc>().add(AddProductColor(newColor));
    } 
    // Si hay menos colores, se eliminó uno
    else if (newColors.length < colors.length) {
      // Encontrar qué color falta
      for (int i = 0; i < colors.length; i++) {
        bool found = false;
        for (var newColor in newColors) {
          if (newColor.idColor == colors[i].idColor &&
              newColor.name == colors[i].name) {
            found = true;
            break;
          }
        }
        if (!found) {
          context.read<ProductFormBloc>().add(RemoveProductColor(i));
          break;
        }
      }
    }
  }
}