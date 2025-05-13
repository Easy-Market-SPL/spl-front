import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';

import '../../models/helpers/intern_logic/user_type.dart';
import '../../models/users_models/user.dart';
import '../../widgets/logic_widgets/profile_management_widgets/profile_header.dart';
import '../../widgets/logic_widgets/profile_management_widgets/profile_section.dart';

class DeliveryProfilePage extends StatefulWidget {
  const DeliveryProfilePage({super.key});

  @override
  DeliveryProfilePageState createState() => DeliveryProfilePageState();
}

class DeliveryProfilePageState extends State<DeliveryProfilePage> {
  // Create the controllers for the username and name fields
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    userNameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel user =
        BlocProvider.of<UsersBloc>(context).state.sessionUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    child: Column(
                      children: [
                        // Header
                        ProfileHeader(
                          userName: user.fullname,
                          userRoleTitle: ProfileStrings.deliveryTitle,
                          userRoleDescription:
                              ProfileStrings.roleDescriptionDelivery(
                                  user.fullname),
                        ),
                        const SizedBox(height: 20),

                        // Profile Section
                        ProfileSection(
                          userNameController: userNameController,
                          nameController: nameController,
                          userType: UserType.delivery,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
