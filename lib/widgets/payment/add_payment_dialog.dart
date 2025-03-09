import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/inputs/card_input.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  AddPaymentDialogState createState() => AddPaymentDialogState();
}

class AddPaymentDialogState extends State<AddPaymentDialog> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController ccvController = TextEditingController();
  bool isCardValid = false;
  bool isExpirationValid = false;
  bool isCcvValid = false;

  @override
  void initState() {
    super.initState();
    cardNumberController.addListener(_validateCardNumber);
    expirationController.addListener(_formatExpirationDate);
    ccvController.addListener(_validateCcv);
    firstNameController.addListener(_updateCard);
    lastNameController.addListener(_updateCard);
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    expirationController.dispose();
    ccvController.dispose();
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
                      '${firstNameController.text} ${lastNameController.text}',
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
                controller: firstNameController,
                labelText: ProfileStrings.nameLabel,
                hintText: ProfileStrings.nameHint,
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: lastNameController,
                labelText: ProfileStrings.lastNameLabel,
                hintText: ProfileStrings.lastNameHint,
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
                      ? () {
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
