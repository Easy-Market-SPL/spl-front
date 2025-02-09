import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/inputs/card_input.dart';

class AddPaymentDialog extends StatelessWidget {
  AddPaymentDialog({super.key});

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController ccvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        color: Colors.white,
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

              // Payment card image with curved borders
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/images/payment_card.jpg",
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fields stacked one below another
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
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              CardInput(
                controller: ccvController,
                labelText: ProfileStrings.ccvLabel,
                hintText: ProfileStrings.ccvHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
