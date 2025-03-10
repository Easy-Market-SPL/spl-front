import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/profile_tab/profile_tab_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/buttons/profile_save_changes_button.dart';
import 'package:spl_front/widgets/payment/payment_list_section.dart';
import 'package:spl_front/widgets/profile/profile_header.dart';
import 'package:spl_front/widgets/profile/profile_section.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for the profile information
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            children: [
              // Profile Header
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: ProfileHeader(
                  userRoleTitle: ProfileStrings.customerTitle,
                  userRoleDescription: ProfileStrings.roleDescription,
                ),
              ),

              // Row of buttons
              buildSectionButtons(),

              const SizedBox(height: 20),

              // Main content based on selected tab, according with the state
              Expanded(
                child: BlocBuilder<ProfileTabBloc, ProfileTabState>(
                  builder: (context, state) {
                    if (state.informationTab) {
                      return Column(
                        children: [
                          Expanded(
                            child: ProfileSection(
                              userNameController: userNameController,
                              nameController: nameController,
                            ),
                          ),
                          SaveChangesButton(
                            onPressed: () {
                              // TODO: Implement Save changes logic
                              // print("Username: ${userNameController.text}");
                              // print("Name: ${nameController.text}");
                            },
                          ),
                        ],
                      );
                    } else {
                      return const PaymentMethodsSection();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BlocBuilder<ProfileTabBloc, ProfileTabState> buildSectionButtons() {
    return BlocBuilder<ProfileTabBloc, ProfileTabState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileTabBloc>().add(ChangeTab(true));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      state.informationTab ? Colors.blue : Colors.grey[200],
                  foregroundColor:
                      state.informationTab ? Colors.white : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(ProfileStrings.information),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileTabBloc>().add(ChangeTab(false));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      !state.informationTab ? Colors.blue : Colors.grey[200],
                  foregroundColor:
                      !state.informationTab ? Colors.white : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(ProfileStrings.paymentMethods),
              ),
            ),
          ],
        );
      },
    );
  }
}
