import 'package:spl_front/models/logic/user_type.dart';

class UIUserTypeHelper {
  static String getAvatarTextFromUserType(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return 'UC';
      case UserType.business:
        return 'UE';
      case UserType.delivery:
        return 'UD';
    }
  }
}