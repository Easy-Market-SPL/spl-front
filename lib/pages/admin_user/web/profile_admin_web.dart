import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users_management/users_management_bloc.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/models/users_models/user.dart';
import 'package:spl_front/services/api_services/user_service/user_service.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/utils/ui/snackbar_manager_web.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/admin_dialogs/add_user_admin_dialog.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/admin_dialogs/delete_permanently_user_admin_dialog.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/admin_dialogs/edit_user_admin_dialog.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/admin_dialogs/restore_user_admin_dialog.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/admin_dialogs/soft_delete_user_admin_dialog.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/profile_header.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/user_cards/soft_deleted_user_card.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/user_cards/user_card.dart';
import 'package:spl_front/widgets/style_widgets/buttons/add_user_admin_button.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

class AdminPanelWebPage extends StatefulWidget {
  const AdminPanelWebPage({super.key});

  @override
  State<AdminPanelWebPage> createState() => _AdminPanelWebPageState();
}

class _AdminPanelWebPageState extends State<AdminPanelWebPage> {
  @override
  void initState() {
    super.initState();
    // Load all users
    final usersBlocManagement = BlocProvider.of<UsersManagementBloc>(context);
    usersBlocManagement.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    // Load the current User
    final UserModel? currentUser = BlocProvider.of<UsersBloc>(context).state.sessionUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WebScaffold(
      userType: UserType.business,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ProfileHeader(
                  userName: currentUser.fullname,
                  userRoleTitle: ProfileStrings.adminTitle,
                  userRoleDescription: ProfileStrings.roleDescriptionAdmin(currentUser.fullname),
                ),
                const SizedBox(height: 32),
                
                // Users management section in a card
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Users List Title
                          Row(
                            children: [
                              const Text(
                                ProfileStrings.userList,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              // Button for view the soft deleted users
                              const WebSoftDeletedUsersButton(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // BlocBuilder that manages the list of users
                          Expanded(
                            child: BlocBuilder<UsersManagementBloc, UsersManagementState>(
                              builder: (context, state) {
                                if (state.users.isEmpty) {
                                  return const Center(child: CustomLoading());
                                }
                                
                                return Column(
                                  children: [
                                    // Users list with responsive grid layout
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          // Calculate number of columns based on width
                                          final double cardWidth = 300;
                                          final int columns = (constraints.maxWidth / cardWidth).floor();
                                          
                                          return GridView.builder(
                                            padding: EdgeInsets.zero,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: columns > 0 ? columns : 1,
                                              childAspectRatio: 3,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                            ),
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
                                                    builder: (_) => EditUserDialog(user: user),
                                                  );
                                                },
                                                onDelete: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => SoftDeleteUserDialog(user: user),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    
                                    // Add user button at the bottom
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: Center(
                                        child: AddUserButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AddUserDialog(),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebSoftDeletedUsersButton extends StatelessWidget {
  const WebSoftDeletedUsersButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.delete_outline, color: Colors.red,),
      label: const Text('Ver Usuarios Eliminados'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        // Load all users soft deleted
        final List<UserModel> usersDeleted = await UserService.getSoftDeletedUsers();
        
        if (!context.mounted) return;
        
        if (usersDeleted.isEmpty) {
          SnackbarManager.showInfo(
            context,
            message: 'No hay usuarios eliminados',
          );
          return;
        }
        
        // Use a more web-friendly dialog size
        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Usuarios Eliminados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: usersDeleted.length,
                        itemBuilder: (_, index) {
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
                                builder: (_) => RestoreUserAdminDialog(user: user),
                              );
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (_) => DeletePermanentlyUserDialog(user: user),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}