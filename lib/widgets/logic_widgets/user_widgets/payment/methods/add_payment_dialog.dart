import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/style_widgets/inputs/card_input.dart';

import '../../../../../bloc/users_session_information_blocs/address_bloc/address_bloc.dart';
import '../../../../../bloc/users_session_information_blocs/payment_bloc/payment_bloc.dart';
import '../../../../../models/helpers/ui_models/credit_card/address_payment_model.dart';
import '../../../../../models/users_models/address.dart';
import '../../../../../models/users_models/payment_method.dart';
import '../../../../../services/api_services/user_service/user_service.dart';
import '../../../../../services/external_services/google_maps/map_service.dart';

class AddPaymentDialog extends StatefulWidget {
  final Address? address;
  const AddPaymentDialog({super.key, this.address});

  @override
  AddPaymentDialogState createState() => AddPaymentDialogState();
}

class AddPaymentDialogState extends State<AddPaymentDialog> {
  // ─────────── Controllers ───────────
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController ccvController = TextEditingController();

  bool isCardValid = false;
  bool isExpirationValid = false;
  bool isCcvValid = false;

  List<Address> _userAddresses = [];
  Address? _selectedAddress;
  bool _isLoadingAddresses = false;

  late Address? address;

  // ────────────────────────────────────────────────────────────────────
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
    if (address == null) _fetchUserAddresses();
  }

  Future<void> _fetchUserAddresses() async {
    setState(() => _isLoadingAddresses = true);
    _userAddresses = context.read<AddressBloc>().state.addresses;
    setState(() => _isLoadingAddresses = false);
  }

  void _updateCard() => setState(() {});

  void _validateCardNumber() {
    String text = cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 16) {
      text = text.substring(0, 16);
      cardNumberController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    setState(() => isCardValid = text.length == 16);
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
    setState(() => isCcvValid = text.length == 3);
  }

  void _formatExpirationDate() {
    String text = expirationController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 4) text = text.substring(0, 4);
    if (text.length > 2) text = '${text.substring(0, 2)}/${text.substring(2)}';
    expirationController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() => isExpirationValid = text.length == 5);
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    expirationController.dispose();
    ccvController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isAddressValid = address != null || _selectedAddress != null;
    final bool canConfirm =
        isCardValid && isExpirationValid && isCcvValid && isAddressValid;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(ProfileStrings.addPaymentCard,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              CreditCardWidget(
                cardNumber: cardNumberController.text,
                expiryDate: expirationController.text,
                cardHolderName:
                    '${nameController.text} ${emailController.text}',
                cvvCode: ccvController.text,
                showBackView: false,
                onCreditCardWidgetChange: (_) {},
              ),
              const SizedBox(height: 16),

              CardInput(
                  controller: cardNumberController,
                  labelText: ProfileStrings.cardLabel,
                  hintText: ProfileStrings.cardHint,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              CardInput(
                  controller: nameController,
                  labelText: ProfileStrings.nameLabel,
                  hintText: ProfileStrings.nameHint),
              const SizedBox(height: 16),
              CardInput(
                  controller: emailController,
                  labelText: ProfileStrings.emailCreateLabel,
                  hintText: ProfileStrings.emailCreateHint),
              const SizedBox(height: 16),
              CardInput(
                  controller: phoneController,
                  labelText: ProfileStrings.phoneLabel,
                  hintText: ProfileStrings.phoneNameHint,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              CardInput(
                  controller: expirationController,
                  labelText: ProfileStrings.expirationDateLabel,
                  hintText: ProfileStrings.expirationDateHint,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              CardInput(
                  controller: ccvController,
                  labelText: ProfileStrings.ccvLabel,
                  hintText: ProfileStrings.ccvHint,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 24),

              // ─── Address ───
              if (widget.address == null) ...[
                const Text('Dirección de envío',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (_isLoadingAddresses)
                  const Center(child: CircularProgressIndicator())
                else if (_userAddresses.isEmpty)
                  const Text('No tienes direcciones registradas.')
                else
                  SafeArea(
                      child: DropdownButtonFormField<Address>(
                    isExpanded: true,
                    value: _selectedAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Selecciona una dirección',
                      isDense: true,
                    ),
                    items: _userAddresses
                        .map((addr) => DropdownMenuItem<Address>(
                              value: addr,
                              child: Text(
                                addr.address,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedAddress = value),
                  )),
                const SizedBox(height: 24),
              ],

              // ─── Botón confirmar ───
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canConfirm ? _onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(ProfileStrings.saveCard,
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirm Action
  Future<void> _onConfirm() async {
    _showLoadingDialog(context);
    try {
      final paymentBloc = context.read<PaymentBloc>();
      final userId = context.read<UsersBloc>().state.sessionUser!.id;

      final Address chosen = address ?? _selectedAddress!;

      final mapService = MapService();
      AddressPaymentModel paymentAddr;
      final googleInfo = await mapService.getInformationByCoorsGoogle(
        LatLng(chosen.latitude, chosen.longitude),
      );

      if (googleInfo.isNotEmpty) {
        final result = googleInfo.first;
        paymentAddr = AddressPaymentModel(
          city: 'Bogotá D.C.',
          country: 'CO',
          line1: chosen.address.toString(),
          line2: chosen.details.toString(),
          state: 'Unknown',
          postalCode:
              result.addressComponents.lastOrNull?.shortName ?? '110111',
        );
      } else {
        paymentAddr = AddressPaymentModel(
          city: 'Bogotá D.C.',
          country: 'CO',
          line1: chosen.address.toString(),
          line2: chosen.details.toString(),
          state: 'N/A',
          postalCode: 'N/A',
        );
      }

      final paymentMethod = PaymentMethodCard(
        cardNumber: cardNumberController.text,
        email: emailController.text,
        phone: phoneController.text,
        cvv: ccvController.text,
        expiryDate: expirationController.text,
        cardHolderName: nameController.text,
        address: paymentAddr,
      );

      final saved =
          await UserService.createUserPaymentMethod(userId, paymentMethod);
      if (saved == null) {
        _showErrorCreatingDialog(context);
        return;
      }
      paymentBloc.add(AddCardEvent(saved));
      Navigator.pop(context); // Pop loading dialog
      Navigator.pop(context); // Pop add payment dialog
    } catch (_) {
      _showErrorCreatingDialog(context);
      Navigator.pop(context); // Pop loading dialog
      Navigator.pop(context); // Pop add payment dialog
    } finally {
      // Close the loading dialog if it is still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _showErrorCreatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Error en la creación del método de pago',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                'No ha sido posible crear el método de pago. Por favor, verifica los datos ingresados.',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Center(
          child: Text(
            'Creando Método de Pago...',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payment_rounded, color: Colors.blue, size: 50),
            const SizedBox(height: 10),
            Text(
              'Por favor, espera un momento.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
