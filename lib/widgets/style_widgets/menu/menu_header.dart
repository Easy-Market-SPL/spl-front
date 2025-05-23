import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';

import '../../../models/helpers/intern_logic/user_type.dart';

class MenuHeader extends StatelessWidget {
  final UserType userType;

  const MenuHeader({super.key, required this.userType});

  String initialsName(String userName) {
    return userName.substring(0, 2).toUpperCase();
  }

  String getUserRole(String userType) {
    switch (userType) {
      case 'admin':
        return 'Administrador';
      case 'customer':
        return 'Cliente';
      case 'business':
        return 'Gestor productos';
      case 'delivery':
        return 'Repartidor';
      default:
        return 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = BlocProvider.of<UsersBloc>(context);
    final user = userProvider.state.sessionUser;

    // Handle null user case
    if (user == null) {
      return Container(
        color: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.only(left: 20, top: 60, bottom: 20, right: 10),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overflow: TextOverflow.ellipsis,
                  user.fullname,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  getUserRole(user.rol),
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
