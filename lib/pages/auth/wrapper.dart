import 'package:flutter/cupertino.dart';
import 'package:spl_front/routes/routes.dart';

import '../../services/supabase/supabase_config.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: SupabaseConfig().client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final authState = snapshot.data;

          if (authState == null) {
            return const Text("Error desconocido");
          } else {
            final session = authState.session;
            if (session != null) {
              var userRole = 'customer'; // user.role
              if (userRole == 'admin' || userRole == 'business') {
                return appRoutes['business_dashboard']!(context);
              } else if (userRole == 'delivery') {
                return appRoutes['delivery_user_orders']!(context);
              } else if (userRole == 'customer') {
                return appRoutes['customer_dashboard']!(context);
              }
            } else {
              return appRoutes['login']!(context);
            }
          }
          return appRoutes['login']!(context);
        });
  }
}
