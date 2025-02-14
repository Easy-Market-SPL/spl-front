import 'package:flutter/material.dart';

class LabelsProvider extends ChangeNotifier {
  final List<String> _labels = [];

  List<String> get labels => _labels;

  void addLabel(String label) {
    if (!_labels.contains(label)) {
      _labels.add(label);
      notifyListeners();
    }
  }

  void removeLabel(String label) {
    _labels.remove(label);
    notifyListeners();
  }
}
