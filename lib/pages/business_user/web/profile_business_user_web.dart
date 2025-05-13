import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/profile_header.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/profile_section.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

class BusinessUserProfileWebPage extends StatefulWidget {
  const BusinessUserProfileWebPage({super.key});

  @override
  State<BusinessUserProfileWebPage> createState() => _BusinessUserProfileWebPageState();
}

class _BusinessUserProfileWebPageState extends State<BusinessUserProfileWebPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = BlocProvider.of<UsersBloc>(context);
    final user = userProvider.state.sessionUser;
    if (user != null) {
      userNameController.text = user.username;
      nameController.text = user.fullname;
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      userType: UserType.business,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card for profile information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section
                        BlocBuilder<UsersBloc, UsersState>(
                          builder: (context, state) {
                            final user = state.sessionUser;
                            if (user == null) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            return ProfileHeader(
                              userName: user.username,
                              userRoleTitle: ProfileStrings.businessTitle,
                              userRoleDescription: ProfileStrings.roleDescriptionBusiness(user.fullname),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Form section - adapt layout for web
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 600
                                ? _buildWideLayout()
                                : _buildNarrowLayout();
                          },
                        ),
                      ],
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

  // Two column layout for wider screens
  Widget _buildWideLayout() {
    return ProfileSection(
      userNameController: userNameController,
      nameController: nameController,
      userType: UserType.business,
    );
  }

  // Single column layout for narrow screens
  Widget _buildNarrowLayout() {
    return ProfileSection(
      userNameController: userNameController,
      nameController: nameController,
      userType: UserType.business,
    );
  }
}