import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users_management/users_management_bloc.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/profile/add_user_admin_dialog.dart';
import 'package:spl_front/widgets/profile/profile_header.dart';
import 'package:spl_front/widgets/profile/user_card.dart';

import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/user.dart';
import '../../utils/strings/profile_strings.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  @override
  void initState() {
    super.initState();

    /// Load all users
    final usersBlocManagement = BlocProvider.of<UsersManagementBloc>(context);
    usersBlocManagement.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    /// Load the current User
    final UserModel currentUser =
        BlocProvider.of<UsersBloc>(context).state.sessionUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ProfileHeader(
                userName: currentUser.fullname,
                userRoleTitle: ProfileStrings.adminTitle,
                userRoleDescription:
                    ProfileStrings.roleDescriptionAdmin(currentUser.fullname),
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
              // BlocBuilder that manage the list of users, and if is empty or loading show a loading widget
              BlocBuilder<UsersManagementBloc, UsersManagementState>(
                builder: (context, state) {
                  if (state.users.isEmpty) {
                    return const SizedBox(
                      height: 300,
                      child: CustomLoading(),
                    );
                  }
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.users.length,
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return UserCard(
                            name: user.fullname,
                            role: user.rol,
                            initial: user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : '',
                            onEdit: () {
                              // TODO: Implement onEdit
                            },
                            onDelete: () {
                              // TODO: Implement onDelete
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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
                  );
                },
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
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
