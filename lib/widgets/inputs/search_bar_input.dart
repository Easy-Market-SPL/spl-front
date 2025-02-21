import 'package:flutter/material.dart';

class SearchBarInput extends StatelessWidget {
  final String? hintText;
  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onFilterPressed;
  final bool showFilterButton;

  const SearchBarInput({
    super.key, 
    this.hintText = "",
    required this.focusNode,
    required this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.onFilterPressed,
    this.showFilterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        focusNode: focusNode, // Assign the focusNode to the TextField
        controller: controller,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onTapOutside: (event) => focusNode.unfocus(),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search),
          suffixIcon: showFilterButton
              ? IconButton(
                  icon: Icon(Icons.filter_alt),
                  onPressed: onFilterPressed,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}