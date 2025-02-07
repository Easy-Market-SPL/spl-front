import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/buttons/profile_save_changes.dart';
import 'package:spl_front/widgets/profile/profile_header.dart';
import 'package:spl_front/widgets/profile/profile_section.dart';

class DeliveryProfilePage extends StatelessWidget {
  const DeliveryProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the controllers for the username and name fields
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            children: [
              // Main content with Scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: Pass the information of the user when the login is implemented
                        const ProfileHeader(
                            userRoleTitle: ProfileStrings.deliveryTitle,
                            userRoleDescription:
                                ProfileStrings.roleDescription),
                        const SizedBox(height: 20),

                        // Profile Section for modify the information
                        ProfileSection(
                            nameController: nameController,
                            userNameController: userNameController),
                      ],
                    ),
                  ),
                ),
              ),

              // Button for save changes.
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SaveChangesButton(
                  onPressed: () {
                    //TODO: Implement the logic for save the changes of the delivery user, pass the user as parameter to the component
                    // print("Save changes");
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
