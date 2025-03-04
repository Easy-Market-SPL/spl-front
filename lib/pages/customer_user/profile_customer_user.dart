import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/profile_tab/profile_tab_bloc.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/addresses/address_section.dart';
import 'package:spl_front/widgets/buttons/log_out_button.dart';
import 'package:spl_front/widgets/buttons/profile_save_changes_button.dart';
import 'package:spl_front/widgets/payment/payment_list_section.dart';
import 'package:spl_front/widgets/profile/profile_header.dart';
import 'package:spl_front/widgets/profile/profile_section.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  @override
  void initState() {
    super.initState();
  }

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
                    if (state.showedTab == 0) {
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
                              Navigator.pop(context);
                            },
                          ),
                          LogOutButton(),
                        ],
                      );
                    } else if (state.showedTab == 1) {
                      return const PaymentMethodsSection();
                    } else {
                      return AddressSection();
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
                  context.read<ProfileTabBloc>().add(ChangeTab(0));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      state.showedTab == 0 ? Colors.blue : Colors.grey[200],
                  foregroundColor:
                      state.showedTab == 0 ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  ProfileStrings.information,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileTabBloc>().add(ChangeTab(1));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      state.showedTab == 1 ? Colors.blue : Colors.grey[200],
                  foregroundColor:
                      state.showedTab == 1 ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  ProfileStrings.paymentMethods,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileTabBloc>().add(ChangeTab(2));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      state.showedTab == 2 ? Colors.blue : Colors.grey[200],
                  foregroundColor:
                      state.showedTab == 2 ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  ProfileStrings.addresses,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
