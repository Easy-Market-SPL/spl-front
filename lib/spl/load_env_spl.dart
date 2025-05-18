import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spl_front/spl/spl_variables.dart';

class LoadSPLClass {
  static bool _envToBool(String key) =>
      (dotenv.env[key]?.toLowerCase() == 'true');

  static Future<void> initializateSPLVariables() async {
    final setters = <void Function(bool)>[
      (v) => SPLVariables.isRated = v,
      (v) => SPLVariables.hasChat = v,
      (v) => SPLVariables.hasThirdAuth = v,
      (v) => SPLVariables.hasRealTimeTracking = v,
      (v) => SPLVariables.hasCashPayment = v,
      (v) => SPLVariables.hasCreditCardPayment = v
    ];

    const envKeys = [
      'RATINGS_ENABLED',
      'CHAT_ENABLED',
      'THIRD_AUTH_ENABLED',
      'REAL_TIME_TRACKING_ENABLED',
      'CASH_PAYMENT_ENABLED',
      'CREDIT_CARD_ENABLED'
    ];

    for (var i = 0; i < envKeys.length; i++) {
      setters[i](_envToBool(envKeys[i]));
      print('${envKeys[i]}: ${setters[i]}');
    }
  }
}
