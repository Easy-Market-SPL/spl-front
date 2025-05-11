import 'package:flutter/material.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/pages/customer_user/payment/payment_method_selection.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

class PaymentMethodSelectionWeb extends StatelessWidget{
  const PaymentMethodSelectionWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WebScaffold(
      userType: UserType.customer,
      body: Center(
        child: SizedBox(
          width: 800,
          height: screenSize.height * 0.9,
          child: const SelectPaymentMethodScreen(),
        ),
      ),
    );
  }
}