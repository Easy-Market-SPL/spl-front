import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/order_strings.dart';
import 'package:spl_front/widgets/inputs/search_bar_input.dart';

class SearchBarSection extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const SearchBarSection({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBarInput(
      controller: searchController,
      hintText: OrderStrings.searchOrdersHint,
      onEditingComplete: () {
        onSearch(searchController.text);
      },
      onSubmitted: (value) {
        onSearch(value);
      },
      onTapOutside: () {
        onSearch(searchController.text);
      },
      focusNode: FocusNode(),
    );
  }
}