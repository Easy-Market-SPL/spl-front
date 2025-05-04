import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users_management/users_management_bloc.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/users_models/user.dart';
import '../../services/api_services/user_service/user_service.dart';
import '../../utils/strings/profile_strings.dart';
import '../../widgets/logic_widgets/profile_management_widgets/admin_dialogs/add_user_admin_dialog.dart';
import '../../widgets/logic_widgets/profile_management_widgets/admin_dialogs/delete_permanently_user_admin_dialog.dart';
import '../../widgets/logic_widgets/profile_management_widgets/admin_dialogs/edit_user_admin_dialog.dart';
import '../../widgets/logic_widgets/profile_management_widgets/admin_dialogs/restore_user_admin_dialog.dart';
import '../../widgets/logic_widgets/profile_management_widgets/admin_dialogs/soft_delete_user_admin_dialog.dart';
import '../../widgets/logic_widgets/profile_management_widgets/profile_header.dart';
import '../../widgets/logic_widgets/profile_management_widgets/user_cards/soft_deleted_user_card.dart';
import '../../widgets/logic_widgets/profile_management_widgets/user_cards/user_card.dart';
import '../../widgets/style_widgets/buttons/add_user_admin_button.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Return to the previous page
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
              Row(
                children: [
                  const Text(
                    ProfileStrings.userList,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Button for view the soft deleted users
                  ButtonSoftDeletedUsers()
                ],
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
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return EditUserDialog(user: user);
                                },
                              );
                            },
                            onDelete: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SoftDeleteUserDialog(user: user);
                                  });
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
                      const SizedBox(height: 20),
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

class ButtonSoftDeletedUsers extends StatelessWidget {
  const ButtonSoftDeletedUsers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: const Text('Eliminados Parcialmente'),
      selected: false,
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      showCheckmark: false,
      labelStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        overflow: TextOverflow.ellipsis,
      ),
      onSelected: (_) async {
        /// Load all users soft deleted
        final List<UserModel> usersDeleted =
            await UserService.getSoftDeletedUsers();
        if (usersDeleted.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay usuarios eliminados',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Usuarios Eliminados\nParcialmente',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              content: SizedBox(
                height: 400,
                width: 300,
                child: ListView.builder(
                  itemCount: usersDeleted.length,
                  itemBuilder: (context, index) {
                    final user = usersDeleted[index];
                    return SoftDeletedUserCard(
                      name: user.fullname,
                      role: user.rol,
                      initial: user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : '',
                      onRestore: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return RestoreUserAdminDialog(user: user);
                          },
                        );
                      },
                      onDelete: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return DeletePermanentlyUserDialog(user: user);
                            });
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
