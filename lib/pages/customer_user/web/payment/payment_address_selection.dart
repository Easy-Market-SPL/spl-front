import 'package:flutter/material.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/pages/customer_user/payment/payment_address_selection.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

class PaymentAddressSelection extends StatelessWidget{
  const PaymentAddressSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      userType: UserType.customer,
      body: Center(child: SizedBox(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.9,
        child: const SelectAddressScreen(),
      ),)
    );
  }
}