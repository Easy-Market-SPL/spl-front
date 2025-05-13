import 'package:flutter/material.dart';

class ProductFormProvider extends ChangeNotifier {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController(text: '0.0');
  
  // Valores originales para respaldo
  String _originalName = '';
  String _originalCode = '';
  String _originalDescription = '';
  String _originalPrice = '';
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Puedes inicializarlos o asignarlos según un producto existente
  void loadProduct({
    required String name,
    required String code,
    required String description,
    required String price,
  }) {
    // Guardar valores originales
    _originalName = name;
    _originalCode = code;
    _originalDescription = description;
    _originalPrice = price;
    
    // Asignar a controladores
    nameController.text = name;
    codeController.text = code;
    descriptionController.text = description;
    priceController.text = price;
    
    _isInitialized = true;
    notifyListeners();
    
    debugPrint('ProductFormProvider - Después de cargar: name=$name, controller=${nameController.text}');
  }
  
  // Obtener valores originales o actuales según corresponda
  String get name => nameController.text.isNotEmpty ? nameController.text : _originalName;
  String get code => codeController.text.isNotEmpty ? codeController.text : _originalCode;
  String get description => descriptionController.text.isNotEmpty ? descriptionController.text : _originalDescription;
  String get price => priceController.text.isNotEmpty ? priceController.text : _originalPrice;

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}