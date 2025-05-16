import '../../models/helpers/intern_logic/user_type.dart';

class UIUserTypeHelper {
  static bool isAdmin = false;
  static String getAvatarTextFromUserType(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return 'UC';
      case UserType.business:
        return 'UE';
      case UserType.delivery:
        return 'UD';
      case UserType.admin:
        return 'AD';
    }
  }

  static String getAvatarTextFromUserName(String userName) {
    return userName.substring(0, 2);
  }
}
