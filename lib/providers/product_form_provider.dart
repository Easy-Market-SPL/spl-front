import 'dart:io';

import 'package:flutter/foundation.dart';

class ProductFormProvider extends ChangeNotifier {
  File? _selectedImage;
  final List<String> _selectedTags = [];

  File? get selectedImage => _selectedImage;
  List<String> get selectedTags => _selectedTags;

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  /// Method to toggle the selection of a tag
  void toggleTagSelection(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void removeTag(String tag) {
    _selectedTags.remove(tag);
    notifyListeners();
  }
}
