import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_blocs/profile_tab_bloc/profile_tab_bloc.dart';
import 'package:spl_front/bloc/users_blocs/users/users_bloc.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/models/users_models/user.dart';
import 'package:spl_front/utils/strings/profile_strings.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/profile_header.dart';
import 'package:spl_front/widgets/logic_widgets/profile_management_widgets/profile_section.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/addresses/address_section.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/payment/methods/payment_list_section.dart';
import 'package:spl_front/widgets/web/scaffold_web.dart';

class CustomerProfileWebPage extends StatefulWidget {
  const CustomerProfileWebPage({super.key});

  @override
  State<CustomerProfileWebPage> createState() => _CustomerProfileWebPageState();
}

class _CustomerProfileWebPageState extends State<CustomerProfileWebPage> {
  // The controllers for the username and name fields
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final UserModel? user = BlocProvider.of<UsersBloc>(context).state.sessionUser;
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
    final UserModel? user = BlocProvider.of<UsersBloc>(context).state.sessionUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WebScaffold(
      userType: UserType.customer,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                ProfileHeader(
                  userName: user.fullname,
                  userRoleTitle: ProfileStrings.customerTitle,
                  userRoleDescription: ProfileStrings.roleDescriptionCustomer(user.fullname),
                ),
                const SizedBox(height: 24),

                // Tab buttons in a more web-friendly layout
                buildSectionButtons(),
                const SizedBox(height: 24),

                // Main content in a card with better web layout
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BlocBuilder<ProfileTabBloc, ProfileTabState>(
                        builder: (context, state) {
                          if (state.showedTab == 0) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Two-column layout for wider screens
                                      if (constraints.maxWidth > 600) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: ProfileSection(
                                                userNameController: userNameController,
                                                nameController: nameController,
                                                userType: UserType.customer,
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return ProfileSection(
                                          userNameController: userNameController,
                                          nameController: nameController,
                                          userType: UserType.customer,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else if (state.showedTab == 1) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: PaymentMethodsSection(),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: AddressSection(),
                            );
                          }
                        },
                      ),
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

  Widget buildSectionButtons() {
    return BlocBuilder<ProfileTabBloc, ProfileTabState>(
      builder: (context, state) {
        return Wrap(
          spacing: 12, // horizontal space between items
          runSpacing: 12, // vertical space between lines
          children: [
            _buildTabButton(0, ProfileStrings.information, state.showedTab),
            _buildTabButton(1, ProfileStrings.paymentMethods, state.showedTab),
            _buildTabButton(2, ProfileStrings.addresses, state.showedTab),
          ],
        );
      },
    );
  }
  
  Widget _buildTabButton(int tabIndex, String label, int currentTab) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 120, // minimum width to prevent tiny buttons
        maxWidth: 180, // maximum width to maintain design
      ),
      child: IntrinsicWidth( // Makes the button take only the space it needs
        child: ElevatedButton(
          onPressed: () => context.read<ProfileTabBloc>().add(ChangeTab(tabIndex)),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentTab == tabIndex ? Colors.blue : Colors.grey[200],
            foregroundColor: currentTab == tabIndex ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}