import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/address_strings.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/addresses/helpers/address_dialogs.dart';

import '../../../../bloc/users_session_information_blocs/address_bloc/address_bloc.dart';

class AddressSection extends StatelessWidget {
  const AddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final addressBloc = BlocProvider.of<AddressBloc>(context);
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                AddressStrings.deliveryAddresses,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // List of addresses
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.addresses.length,
                itemBuilder: (context, index) {
                  final address = state.addresses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(address.name),
                      subtitle: Text(
                        '${address.address.split(',').sublist(0).join(',')}\n${address.details}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Button
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Trigger edit dialog
                              showEditDialog(context, address, index);
                            },
                          ),
                          // Delete Button
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Show confirmation before deletion
                              showDeleteConfirmationDialog(
                                  context, addressBloc, index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, 'add_address');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AddressStrings.addAddress,
                    style: TextStyle(color: Colors.white),
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
