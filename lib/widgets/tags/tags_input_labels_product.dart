import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spl_front/providers/product_form_provider.dart';
import 'package:spl_front/providers/selected_labels_provider.dart';
import 'package:spl_front/utils/strings/labels_strings.dart';

class TagsInputWidget extends StatelessWidget {
  const TagsInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final productFormProvider = Provider.of<ProductFormProvider>(context);
    final labelsProvider = Provider.of<LabelsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(LabelsStrings.labels,
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownSearch<String>(
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                labelText: LabelsStrings.searchLabels,
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
              ),
            ),
            emptyBuilder: (context, searchEntry) {
              if (searchEntry.isEmpty) return const SizedBox();
              return ListTile(
                title: Text(LabelsStrings.addLabel + searchEntry),
                trailing: const Icon(Icons.add_circle, color: Colors.blue),
                onTap: () {
                  if (searchEntry.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(LabelsStrings.handleEmptyLabel),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  labelsProvider.addLabel(searchEntry);
                  productFormProvider.toggleTagSelection(searchEntry);
                  Navigator.pop(context);
                },
              );
            },
          ),
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: LabelsStrings.selectLabel,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          items: (filter, _) => labelsProvider.labels
              .where((tag) => !productFormProvider.selectedTags.contains(tag))
              .where((tag) => tag.toLowerCase().contains(filter.toLowerCase()))
              .toList(),
          onSaved: (value) {
            if (value != null) productFormProvider.toggleTagSelection(value);
          },
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: productFormProvider.selectedTags.map((tag) {
            return Chip(
              label: Text(tag, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
              deleteIcon:
                  const Icon(Icons.close, size: 16, color: Colors.white),
              onDeleted: () => productFormProvider.removeTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}
