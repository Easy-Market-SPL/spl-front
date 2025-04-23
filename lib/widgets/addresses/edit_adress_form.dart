import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/address_strings.dart';

import '../../models/logic/address.dart';

class EditAddressForm extends StatelessWidget {
  final Address address;
  final TextEditingController nameController;
  final TextEditingController detailsController;

  const EditAddressForm(
      {super.key,
      required this.address,
      required this.nameController,
      required this.detailsController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: AddressStrings.inputLabelName),
        ),
        TextField(
          controller: detailsController,
          decoration:
              InputDecoration(labelText: AddressStrings.inputLabelDetails),
        ),
      ],
    );
  }
}
