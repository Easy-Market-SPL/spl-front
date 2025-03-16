import 'package:spl_front/models/data/variant_option.dart';

class Variant {
  String name;
  List<VariantOption> options;

  Variant({required this.name, required this.options});
}