import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_event.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_state.dart';
import 'package:spl_front/utils/prices/price_formatter.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';

class ActiveFiltersDisplay extends StatelessWidget {
  const ActiveFiltersDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFilterBloc, ProductFilterState>(
      builder: (context, state) {
        if (!state.hasActiveFilters) {
          return const SizedBox.shrink();
        }

        final List<Widget> chips = [];
        
        // Minimum price
        if (state.minPrice != null) {
          chips.add(
            Chip(
              label: Text('${DashboardStrings.fromPriceWithValue} ${PriceFormatter.formatPrice(state.minPrice!)}'),
              onDeleted: () => context.read<ProductFilterBloc>().add(
                RemoveFilter(ProductFilterType.minPrice)
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          );
        }
        
        // Maximum price
        if (state.maxPrice != null) {
          chips.add(
            Chip(
              label: Text('${DashboardStrings.toPriceWithValue} ${PriceFormatter.formatPrice(state.maxPrice!)}'),
              onDeleted: () => context.read<ProductFilterBloc>().add(
                RemoveFilter(ProductFilterType.maxPrice)
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          );
        }
        
        // Minimum rating
        if (state.minRating != null && state.minRating! > 0) {
          chips.add(
            Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${DashboardStrings.minRatingWithValue} ${state.minRating!.toStringAsFixed(1)}'),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                ],
              ),
              onDeleted: () => context.read<ProductFilterBloc>().add(
                RemoveFilter(ProductFilterType.minRating)
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          );
        }
        
        // Clear filters button
        if (chips.isNotEmpty) {
          chips.add(
            ActionChip(
              label: const Text(DashboardStrings.clearAll),
              onPressed: () => context.read<ProductFilterBloc>().add(ClearFilters()),
              avatar: const Icon(Icons.clear_all, size: 18),
            ),
          );
        }
        
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        );
      },
    );
  }
}