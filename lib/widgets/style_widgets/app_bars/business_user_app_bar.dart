import 'package:flutter/material.dart';

class BusinessUserAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String hintText;
  final VoidCallback onFilterPressed;
  final TextEditingController searchController;
  final Function(String)? onSearchChanged;

  const BusinessUserAppBar({
    super.key,
    required this.hintText,
    required this.onFilterPressed,
    required this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add spacing
        child: TextField(
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_alt, color: Colors.black),
              onPressed: onFilterPressed,
            ),
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey), // Gray border
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey), // Gray border
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide:
                  BorderSide(color: Colors.blue, width: 2), // Blue border
            ),
          ),
          onTapOutside: (event) {
            FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
          },
          onSubmitted: onSearchChanged,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
