import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/buttons/profile_save_changes_button.dart';
import 'package:spl_front/widgets/profile/profile_header.dart';
import 'package:spl_front/widgets/profile/profile_section.dart';

import '../../widgets/buttons/log_out_button.dart';

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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Header
                        ProfileHeader(
                          userRoleTitle: ProfileStrings.deliveryTitle,
                          userRoleDescription: ProfileStrings.roleDescription,
                        ),
                        const SizedBox(height: 20),

                        // Profile Section
                        ProfileSection(
                          userNameController: userNameController,
                          nameController: nameController,
                        ),
                        const SizedBox(height: 20),

                        // Save Changes Button
                        SaveChangesButton(
                          onPressed: () {
                            // TODO: Implement Save changes logic
                            Navigator.pushReplacementNamed(
                                context, 'delivery_user_orders');
                          },
                        ),
                        const SizedBox(height: 15),

                        // Logout Button
                        const LogOutButton(),
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
