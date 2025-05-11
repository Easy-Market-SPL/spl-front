import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/users_session_information_blocs/address_bloc/address_bloc.dart';
import 'package:spl_front/utils/strings/address_strings.dart';
import 'package:spl_front/widgets/logic_widgets/user_widgets/addresses/helpers/address_dialogs.dart';

class AddressSectionWeb extends StatelessWidget {
  const AddressSectionWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final addressBloc = BlocProvider.of<AddressBloc>(context);
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Direcciones de Entrega",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add_location_alt),
                  label: Text(AddressStrings.addNewAddress),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, 'add_address'),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            if (state.addresses.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      AddressStrings.notAvailableAddresses,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800 ? 3 : 
                                      (constraints.maxWidth > 600 ? 2 : 1);
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.addresses.length,
                    itemBuilder: (context, index) {
                      final address = state.addresses[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      address.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      showEditDialog(
                                        context, address, index
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      showDeleteConfirmationDialog(
                                        context, addressBloc, index
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  address.address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                address.details,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
          ],
        );
      },
    );
  }
}