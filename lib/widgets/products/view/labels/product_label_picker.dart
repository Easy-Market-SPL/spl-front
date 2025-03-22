import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/products_strings.dart';
import 'package:spl_front/widgets/products/view/labels/product_labels_dialog.dart';

class LabelPicker extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const LabelPicker({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<LabelPicker> createState() => _LabelPickerState();
}

class _LabelPickerState extends State<LabelPicker> {
  // For now, availableTags will be fetched via the dialog.
  // In the future, this could be maintained globally or via a provider.

  // void _addCustomTag() async {
  //   final newTag = await showLabelDialog(context);
  //   if (newTag != null && newTag.trim().isNotEmpty) {
  //     setState(() {
  //       if (!widget.tags.contains(newTag.trim())) {
  //         widget.tags.add(newTag.trim());
  //       }
  //     });
  //     widget.onTagsChanged(widget.tags);
  //   }
  // }

  void _selectExistingTag() async {
    final selectedTag = await showLabelDialog(context);
    if (selectedTag != null && selectedTag.trim().isNotEmpty) {
      setState(() {
        if (!widget.tags.contains(selectedTag.trim())) {
          widget.tags.add(selectedTag.trim());
        }
      });
      widget.onTagsChanged(widget.tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      widget.tags.remove(tag);
    });
    widget.onTagsChanged(widget.tags);
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
            for (final tag in widget.tags)
              Chip(
                // Using a fixed padding and style to mimic current design.
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                label: Text(tag, style: const TextStyle(color: Colors.blue)),
                backgroundColor: Colors.white,
                deleteIconColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.blue),
                ),
                onDeleted: () => _removeTag(tag),
              ),
            // Button to select an existing tag.
            InkWell(
              onTap: _selectExistingTag,
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