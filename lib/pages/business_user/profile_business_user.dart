import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/profile/profile_header.dart';
import 'package:spl_front/widgets/profile/profile_section.dart';

import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/user.dart';

class BusinessUserProfilePage extends StatelessWidget {
  const BusinessUserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the controllers for the username and name fields
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    final UserModel user =
        BlocProvider.of<UsersBloc>(context).state.sessionUser!;

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Main content with Scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(
                          userName: user.fullname,
                          userRoleTitle: ProfileStrings.businessTitle,
                          userRoleDescription:
                              ProfileStrings.roleDescriptionBusiness(
                                  user.fullname)),
                      const SizedBox(height: 20),

                      // Profile Section for modify the information
                      ProfileSection(
                        nameController: nameController,
                        userNameController: userNameController,
                        userType: UserType.business,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
