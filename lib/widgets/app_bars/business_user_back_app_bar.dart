import 'package:flutter/material.dart';

class BusinessUserBackAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String hintText;
  final VoidCallback onFilterPressed;

  const BusinessUserBackAppBar({
    super.key,
    required this.hintText,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add spacing
        child: TextField(
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_alt_off, color: Colors.black),
              onPressed: onFilterPressed,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)), //
              borderSide: BorderSide(color: Colors.grey), // Gray border
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: Colors.grey), // Gray border
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide:
                  BorderSide(color: Colors.blue, width: 2), // Blue border
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
