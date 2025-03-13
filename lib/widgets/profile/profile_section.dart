import 'package:flutter/material.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/inputs/custom_input.dart';

import '../../pages/business_user/profile_business_user.dart';

class ProfileSection extends StatefulWidget {
  final TextEditingController userNameController;
  final TextEditingController nameController;
  final String? name;
  final String? userName;

  // TODO: Receive the user, and extract the information to show in the profile at the labels
  const ProfileSection(
      {super.key,
      required this.userNameController,
      required this.nameController,
      this.name,
      this.userName});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: ProfileStrings.information,
        ),
        const SizedBox(height: 24),

        Text(
          ProfileStrings.username,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),

        // TODO: Change the hintText for the correct value (Username)
        CustomInput(
            hintText: ProfileStrings.username,
            textController: widget.userNameController,
            labelText: widget.userName ?? 'JuanFra312003',
            isPassword: false,
            keyboardType: TextInputType.text),
        const SizedBox(height: 24),

        Text(
          ProfileStrings.username,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),

        // TODO: Change the hintText for the correct value (Name)
        CustomInput(
            hintText: ProfileStrings.name,
            textController: widget.nameController,
            labelText: widget.name ?? "Juan Francisco Ramirez",
            isPassword: false,
            keyboardType: TextInputType.text),
        const SizedBox(height: 16),
      ],
    );
  }
}
