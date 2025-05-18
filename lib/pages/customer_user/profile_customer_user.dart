import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/spl/spl_variables.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/payment/methods/payment_list_section.dart';

import '../../bloc/ui_blocs/profile_tab_bloc/profile_tab_bloc.dart';
import '../../bloc/users_blocs/users/users_bloc.dart';
import '../../models/helpers/intern_logic/user_type.dart';
import '../../models/users_models/user.dart';
import '../../widgets/logic_widgets/profile_management_widgets/profile_header.dart';
import '../../widgets/logic_widgets/profile_management_widgets/profile_section.dart';
import '../../widgets/logic_widgets/user_widgets/addresses/address_section.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  // The controllers for the username and name fields
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'customer_dashboard');
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
          child: Column(
            children: [
              // Profile Header
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: ProfileHeader(
                  userName: user.fullname,
                  userRoleTitle: ProfileStrings.customerTitle,
                  userRoleDescription:
                      ProfileStrings.roleDescriptionCustomer(user.fullname),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Row of buttons
              buildSectionButtons(),
              const SizedBox(height: 20),
              // Main content based on selected tab, según el estado
              Expanded(
                child: BlocBuilder<ProfileTabBloc, ProfileTabState>(
                  builder: (context, state) {
                    if (state.showedTab == 0) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            ProfileSection(
                              userNameController: userNameController,
                              nameController: nameController,
                              userType: UserType.customer,
                            )
                          ],
                        ),
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
        return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (SPLVariables.hasCreditCardPayment) ...[
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
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
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
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ]);
      },
    );
  }
}
