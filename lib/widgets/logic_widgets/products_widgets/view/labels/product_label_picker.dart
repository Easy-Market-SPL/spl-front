import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/labels/product_labels_dialog.dart';

import '../../../../../models/product_models/labels/label.dart';

class LabelPicker extends StatefulWidget {
  final List<Label> labels;
  final ValueChanged<List<Label>> onLabelsChanged;

  const LabelPicker({
    super.key,
    required this.labels,
    required this.onLabelsChanged,
  });

  @override
  State<LabelPicker> createState() => _LabelPickerState();
}

class _LabelPickerState extends State<LabelPicker> {
  void _selectExistingLabel() async {
    final selectedLabel = await showLabelDialog(context);
    if (selectedLabel != null) {
      setState(() {
        if (!widget.labels
            .any((label) => label.idLabel == selectedLabel.idLabel)) {
          widget.labels.add(selectedLabel);
        }
      });
      widget.onLabelsChanged(widget.labels);
    }
  }

  void _removeLabel(Label label) {
    setState(() {
      widget.labels.remove(label);
    });
    widget.onLabelsChanged(widget.labels);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          ProductStrings.labels,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in widget.labels)
              Chip(
                // Using a fixed padding and style to mimic current design.
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                label: Text(label.name,
                    style: const TextStyle(color: Colors.blue)),
                backgroundColor: Colors.white,
                deleteIconColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.blue),
                ),
                onDeleted: () => _removeLabel(label),
              ),
            // Button to select an existing tag.
            InkWell(
              onTap: _selectExistingLabel,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  ProductStrings.createLabel,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
