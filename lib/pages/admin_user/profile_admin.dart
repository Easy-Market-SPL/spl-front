import 'package:flutter/material.dart';
import 'package:spl_front/widgets/profile/add_user_admin_dialog.dart';
import 'package:spl_front/widgets/profile/profile_header.dart';
import 'package:spl_front/widgets/profile/user_card.dart';

import '../../utils/strings/profile_strings.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: Load the users information from the DataBase and send it to the widget UserCard instead of the attributes

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ProfileHeader(
                userRoleTitle: ProfileStrings.adminTitle,
                userRoleDescription: ProfileStrings.adminRoleDescription,
              ),

              const SizedBox(height: 20),

              // Users List Title
              const Text(
                ProfileStrings.userList,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // TODO: Send the information and implement the methods (Use BLoC or Provider) and do the map of the users
              // ListView of the users of the System
              Expanded(
                child: ListView(
                  children: [
                    UserCard(
                      name: "Juan Francisco Ramírez",
                      role: "Admin",
                      initial: "JF",
                      onEdit: null,
                      onDelete: null,
                    ),
                    UserCard(
                      name: "Camilo Mora",
                      role: "Admin",
                      initial: "C",
                      onEdit: null,
                      onDelete: null,
                    ),
                  ],
                ),
              ),

              // Add User Button
              Center(
                child: AddUserButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddUserDialog();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddUserButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddUserButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          ProfileStrings.addUser,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
