import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_event.dart';
import 'package:spl_front/bloc/ui_management/product/filter/product_filter_state.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_state.dart';
import 'package:spl_front/models/data/label.dart';
import 'package:spl_front/utils/strings/dashboard_strings.dart';

class LabelsWidget extends StatelessWidget {
  const LabelsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelBloc, LabelState>(
      builder: (context, labelState) {
        if (labelState is LabelInitial || labelState is LabelLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (labelState is LabelDashboardLoaded) {
          return BlocBuilder<ProductFilterBloc, ProductFilterState>(
            builder: (context, filterState) {
              final hasSelectedLabels = filterState.selectedLabels != null && 
                                      filterState.selectedLabels!.isNotEmpty;
              
              // Organices labels, putting the selected ones first
              List<Label> organizedLabels = [];
              final todosLabel = labelState.labels.isNotEmpty ? labelState.labels[0] : null;
              final nonTodosLabels = labelState.labels.skip(1).toList();
              
              List<Label> selectedLabels = [];
              List<Label> nonSelectedLabels = [];

              for (var label in nonTodosLabels) {
                bool isSelected = filterState.selectedLabels?.any(
                  (selectedLabel) => selectedLabel.idLabel == label.idLabel
                ) ?? false;
                
                if (isSelected) {
                  selectedLabels.add(label);
                } else {
                  nonSelectedLabels.add(label);
                }
              }
              
              // Sort the labels: "Todos", selected ones first, then non-selected ones
              if (todosLabel != null) {
                organizedLabels.add(todosLabel);
              }
              organizedLabels.addAll(selectedLabels);
              organizedLabels.addAll(nonSelectedLabels);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Todos" button
                    Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ProductFilterBloc>().add(
                            ApplyFiltersFromDialog(
                              minPrice: filterState.minPrice,
                              maxPrice: filterState.maxPrice,
                              minRating: filterState.minRating,
                              selectedLabels: null,
                            ),
                          );
                          context.read<ProductFilterBloc>().add(ChangeLabelFilter("Todos"));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !hasSelectedLabels ? Colors.blue : Colors.white,
                          foregroundColor: !hasSelectedLabels ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          DashboardStrings.allLabels,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    
                    // Labels
                    ...organizedLabels.skip(1).map((label) {
                      // Check if the label is selected
                      final isSelected = filterState.selectedLabels?.any(
                        (selectedLabel) => selectedLabel.idLabel == label.idLabel
                      ) ?? false;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            if (isSelected) {
                              // If the label is already selected, remove it from the filter
                              final newSelectedLabels = filterState.selectedLabels!
                                  .where((l) => l.idLabel != label.idLabel)
                                  .toList();
                              
                              context.read<ProductFilterBloc>().add(
                                ApplyFiltersFromDialog(
                                  minPrice: filterState.minPrice,
                                  maxPrice: filterState.maxPrice,
                                  minRating: filterState.minRating,
                                  selectedLabels: newSelectedLabels.isEmpty ? null : newSelectedLabels,
                                ),
                              );
                            } else {
                              // If the label is not selected, add it to the filter
                              List<Label> newSelectedLabels = [];
                              if (filterState.selectedLabels != null) {
                                newSelectedLabels = List.from(filterState.selectedLabels!);
                              }
                              newSelectedLabels.add(label);
                              
                              context.read<ProductFilterBloc>().add(
                                ApplyFiltersFromDialog(
                                  minPrice: filterState.minPrice,
                                  maxPrice: filterState.maxPrice,
                                  minRating: filterState.minRating,
                                  selectedLabels: newSelectedLabels,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.blue : Colors.white,
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(
                            label.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        } else if (labelState is LabelError) {
          return Center(child: Text(labelState.message));
        }
        return const SizedBox();
      },
    );
  }
}