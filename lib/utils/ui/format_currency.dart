import 'package:intl/intl.dart';

String formatCurrency(double amount,
    {String locale = 'es_CO', String symbol = '\$'}) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 0,
  );
  return formatter.format(amount);
}
