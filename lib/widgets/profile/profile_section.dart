import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/buttons/log_out_button.dart';
import 'package:spl_front/widgets/buttons/profile_save_changes_button.dart';
import 'package:spl_front/widgets/inputs/custom_input.dart';

import '../../bloc/ui_management/users/users_bloc.dart';
import '../../models/user.dart';
import '../../pages/business_user/profile_business_user.dart';

class ProfileSection extends StatefulWidget {
  final TextEditingController userNameController;
  final TextEditingController nameController;
  final UserType userType;

  // TODO: Receive the user, and extract the information to show in the profile at the labels
  const ProfileSection({
    super.key,
    required this.userNameController,
    required this.nameController,
    required this.userType,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  @override
  Widget build(BuildContext context) {
    // Initial State for the current user
    final userProvider = BlocProvider.of<UsersBloc>(context);
    final UserModel user = userProvider.state.sessionUser!;

    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, usersState) {
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
            CustomInput(
              hintText: user.username,
              textController: widget.userNameController,
              labelText: user.username,
              isPassword: false,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            Text(
              ProfileStrings.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            CustomInput(
              hintText: user.fullname,
              textController: widget.nameController,
              labelText: user.fullname,
              isPassword: false,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            SaveChangesButton(
              onPressed: () => _handleSaveChanges(context),
            ),
            const SizedBox(height: 15),
            LogOutButton(),
          ],
        );
      },
    );
  }

  Future<void> _handleSaveChanges(BuildContext context) async {
    final usersBloc = BlocProvider.of<UsersBloc>(context);
    final UserModel user = usersBloc.state.sessionUser!;
    final String username = widget.userNameController.text;
    final String name = widget.nameController.text;

    // Check if any field has changed and is not empty, for do the respective proccess
    if (username != user.username && username.isNotEmpty) {
      user.username = username;
    }

    if (name != user.fullname && name.isNotEmpty) {
      user.fullname = name;
    }

    await usersBloc.updateUser(user);

    // Show for 1.5 seconds the dialog of EveryThing OK
    _showSuccessfulChangesDialog(context);
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    Navigator.pop(context); // Close the dialog

    // TODO: Do the redirection proccess for admin
    // Redirect according with the role
    if (widget.userType == UserType.customer) {
      Navigator.pushReplacementNamed(context, 'customer_dashboard');
    } else if (widget.userType == UserType.delivery) {
      Navigator.pushReplacementNamed(context, 'delivery_user_orders');
    } else if (widget.userType == UserType.business ||
        widget.userType == UserType.admin) {
      Navigator.pushReplacementNamed(context, 'business_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  void _showSuccessfulChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              ProfileStrings.successFullProfileUpdate,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.blue, size: 50),
              SizedBox(height: 10),
              Text(
                ProfileStrings.successFullProfileUpdateDescription,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
