import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/users_models/user.dart';
import 'user_service.dart';

class UserSyncService {
  static Future<UserModel?> syncExternalUser(User supabaseUser) async {
    try {
      final existingUser = await UserService.getUser(supabaseUser.id);
      
      if (existingUser != null) {
        return existingUser;
      }
      
      // Create user with meta data from Supabase
      final newUser = UserModel(
        id: supabaseUser.id,
        username: _generateUsername(supabaseUser),
        fullname: supabaseUser.userMetadata?['full_name'] ?? 
                 supabaseUser.userMetadata?['name'] ?? 
                 '${supabaseUser.userMetadata?['given_name'] ?? ''} ${supabaseUser.userMetadata?['family_name'] ?? ''}',
        email: supabaseUser.email ?? '',
        rol: 'customer',
      );
      
      final success = await UserService.createUser(newUser);
      
      if (success) {
        return newUser;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  static String _generateUsername(User user) {
    if (user.email != null) {
      // Uses the part before the '@' in the email as username
      return user.email!.split('@')[0];
    } else if (user.userMetadata?['name'] != null) {
      return user.userMetadata!['name'].toString().toLowerCase().replaceAll(' ', '.');
    } else {
      // Fallback: Generates a random username
      return 'user_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }
}