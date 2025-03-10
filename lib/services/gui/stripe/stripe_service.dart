import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:spl_front/models/ui/stripe/stripe_custom_response.dart';

import '../../../models/ui/credit_card/credit_card_model.dart';

class StripeService {
  // Singleton
  StripeService._privateConstructor();
  static final StripeService _instance = StripeService._privateConstructor();
  factory StripeService() => _instance;

  final String _paymentApiUrl = dotenv.env['STRIPE_PAYMENT_API_URL'] ?? '';
  static String secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  final String publicKey = dotenv.env['STRIPE_PUBLIC_KEY'] ?? '';

  final headerOptions = Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      'Authorization': 'Bearer ${StripeService.secretKey}',
    },
  );

  void init() {
    Stripe.publishableKey = publicKey;
    Stripe.instance.applySettings();
  }

  Future<StripeCustomReponse> payWithExistingCard({
    required String amount,
    required String currency,
    required PaymentCardModel card,
  }) async {
    try {
      final String? clientSecret = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      if (clientSecret == null) {
        return StripeCustomReponse(
            ok: false, msg: 'Error al crear el PaymentIntent');
      }

      // Send the data from the Card to Stripe
      await Stripe.instance.dangerouslyUpdateCardDetails(CardDetails(
        number: card.cardNumber,
        expirationMonth: 11,
        expirationYear: 26,
        cvc: card.cvv,
      ));

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: card.email,
              phone: card.phone,
              address: Address(
                city: card.addressPayment.city,
                country: 'CO',
                line1: card.addressPayment.line1,
                line2: card.addressPayment.line2,
                state: card.addressPayment.state,
                postalCode: card.addressPayment.postalCode,
              ),
            ),
          ),
        ),
      );

      final confirmResponse = await _confirmPaymentIntent(
        clientSecret: clientSecret,
        paymentMethodId: paymentMethod.id,
      );

      return confirmResponse;
    } catch (e) {
      debugPrint("Error en payWithExistingCard: $e");
      return StripeCustomReponse(ok: false, msg: e.toString());
    }
  }

  Future<String?> _createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      final dio = Dio();
      final data = {
        'amount': amount,
        'currency': currency,
      };

      final response = await dio.post(
        _paymentApiUrl,
        data: data,
        options: headerOptions,
      );

      return response.data?['client_secret'];
    } catch (e) {
      debugPrint("Error en _createPaymentIntent: $e");
      return null;
    }
  }

  Future<StripeCustomReponse> _confirmPaymentIntent({
    required String clientSecret,
    required String paymentMethodId,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethodId,
          ),
        ),
      );

      return StripeCustomReponse(ok: true, msg: 'Pago exitoso');
    } catch (e) {
      debugPrint("Error en _confirmPaymentIntent: $e");
      return StripeCustomReponse(ok: false, msg: e.toString());
    }
  }
}
