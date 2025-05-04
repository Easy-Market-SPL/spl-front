import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/utils/strings/menu_strings.dart';

import '../../../models/helpers/intern_logic/user_type.dart';
import '../../../models/users_models/user.dart';

class MenuHeader extends StatelessWidget {
  final UserType userType;

  const MenuHeader({super.key, required this.userType});

  String initialsName(String userName) {
    return userName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = BlocProvider.of<UsersBloc>(context);
    final UserModel user = userProvider.state.sessionUser!;

    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.only(left: 20, top: 60, bottom: 20, right: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 25,
            child: Text(
              initialsName(user.fullname),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overflow: TextOverflow.ellipsis,
                user.fullname,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                MenuStrings.myProfile,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
