import 'package:intl/intl.dart';

class PriceFormatter {
  static String formatPrice(double price, 
      {bool withSymbol = true,
      bool withDecimal = false,
      int decimalDigits = 2,
      String locale = 'es_CO',}) 
    {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: withDecimal ? decimalDigits : 0,
    );

    String formatted = formatter.format(price);
    if (withSymbol) {
      return '\$$formatted';
    }
    
    return formatted;
  }
  
  // Parse a formatted price string back to a double
  static double parseFormattedPrice(String formattedPrice) {
    String cleaned = formattedPrice.replaceAll('\$', '')
        .replaceAll('\'', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }
}