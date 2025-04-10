import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_state.dart';

class LabelsWidget extends StatelessWidget {
  final String activeLabel;
  final Function(String) onLabelSelected;
  
  const LabelsWidget({
    super.key, 
    required this.activeLabel, 
    required this.onLabelSelected
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelBloc, LabelState>(
      builder: (context, state) {
        if (state is LabelInitial || state is LabelLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LabelDashboardLoaded) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.labels.map((label) {
                final isSelected = label.name == activeLabel;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    onPressed: () => onLabelSelected(label.name),
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
              }).toList(),
            ),
          );
        } else if (state is LabelError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}