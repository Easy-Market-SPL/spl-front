import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/services/gui/map/map_service.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/inputs/card_input.dart';

import '../../../bloc/ui_management/payment/payment_bloc.dart';
import '../../../models/logic/address.dart';
import '../../../models/ui/credit_card/address_payment_model.dart';
import '../../../models/ui/credit_card/credit_card_model.dart';
import '../../../models/ui/google/places_google_response.dart';

class AddPaymentDialog extends StatefulWidget {
  final Address? address;
  const AddPaymentDialog({super.key, this.address});

  @override
  AddPaymentDialogState createState() => AddPaymentDialogState();
}

class AddPaymentDialogState extends State<AddPaymentDialog> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController ccvController = TextEditingController();
  bool isCardValid = false;
  bool isExpirationValid = false;
  bool isCcvValid = false;
  late Address? address;

  @override
  void initState() {
    super.initState();
    cardNumberController.addListener(_validateCardNumber);
    expirationController.addListener(_formatExpirationDate);
    ccvController.addListener(_validateCcv);
    nameController.addListener(_updateCard);
    emailController.addListener(_updateCard);
    phoneController.addListener(_updateCard);

    address = widget.address;
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    nameController.dispose();
    emailController.dispose();
    expirationController.dispose();
    ccvController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateCard() {
    setState(() {});
  }

  void _validateCardNumber() {
    String text = cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 16) {
      text = text.substring(0, 16);
      cardNumberController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    setState(() {
      isCardValid = text.length == 16;
    });
  }

  void _validateCcv() {
    String text = ccvController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 3) {
      text = text.substring(0, 3);
      ccvController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    setState(() {
      isCcvValid = text.length == 3;
    });
  }

  void _formatExpirationDate() {
    String text = expirationController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }
    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    expirationController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {
      isExpirationValid = text.length == 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                ProfileStrings.addPaymentCard,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: CreditCardWidget(
                  cardNumber: cardNumberController.text,
                  expiryDate: expirationController.text,
                  cardHolderName:
                      '${nameController.text} ${emailController.text}',
                  cvvCode: ccvController.text,
                  showBackView: false,
                  onCreditCardWidgetChange: (creditCardBrand) {},
                ),
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: cardNumberController,
                labelText: ProfileStrings.cardLabel,
                hintText: ProfileStrings.cardHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: nameController,
                labelText: ProfileStrings.nameLabel,
                hintText: ProfileStrings.nameHint,
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: emailController,
                labelText: ProfileStrings.lastNameLabel,
                hintText: ProfileStrings.lastNameHint,
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: phoneController,
                labelText: ProfileStrings.phoneLabel,
                hintText: ProfileStrings.phoneNameHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: expirationController,
                labelText: ProfileStrings.expirationDateLabel,
                hintText: ProfileStrings.expirationDateHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: ccvController,
                labelText: ProfileStrings.ccvLabel,
                hintText: ProfileStrings.ccvHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCardValid && isExpirationValid && isCcvValid
                      ? () async {
                          final paymentBloc =
                              BlocProvider.of<PaymentBloc>(context);
                          late AddressPaymentModel paymentModel;
                          if (widget.address == null) {
                            paymentModel = genericPaymentAddress();
                          } else {
                            MapService mapServiceInstance = MapService();
                            final googlePlacesSearch = await mapServiceInstance
                                .getInformationByCoorsGoogle(LatLng(
                                    widget.address!.latitude,
                                    widget.address!.longitude));

                            if (googlePlacesSearch.isNotEmpty) {
                              print('SE ESTA GUARDANDO CON ESTA INFO');
                              final Result result = googlePlacesSearch.first;
                              paymentModel = AddressPaymentModel(
                                  city: result.addressComponents.last.shortName,
                                  country:
                                      result.addressComponents.last.longName,
                                  line1: widget.address!.address,
                                  line2: widget.address!.details,
                                  state: 'N/A',
                                  postalCode: result.plusCode.toString());
                            }
                          }

                          paymentBloc.add(AddCardEvent(
                            PaymentCardModel(
                              cardNumber: cardNumberController.text,
                              cvv: ccvController.text,
                              email: emailController.text,
                              phone: '+57${phoneController.text}',
                              expiryDate: expirationController.text,
                              cardHolderName: nameController.text,
                              addressPayment: paymentModel,
                            ),
                          ));

                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    ProfileStrings.saveCard,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
