import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/widgets/addresses/address_dialogs.dart';

import '../../bloc/ui_management/address/address_bloc.dart';

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
                'Direcciones de Entrega',
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
                      subtitle: Text('${address.address}\n${address.details}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Button
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Trigger edit dialog
                              AddressDialogs.showEditDialog(
                                  context, address, index);
                            },
                          ),
                          // Delete Button
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Show confirmation before deletion
                              AddressDialogs.showDeleteConfirmationDialog(
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
            //TODO: Implement Add Address functionality when needed
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'add_address');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: MediaQuery.of(context).size.width / 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Agregar Dirección',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
