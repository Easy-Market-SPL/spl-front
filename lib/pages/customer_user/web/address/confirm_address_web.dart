import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/add_address.dart';
import 'package:spl_front/utils/strings/address_strings.dart';

import '../../../../bloc/location_management_bloc/gps_bloc/gps_bloc.dart';
import '../../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import '../../../../bloc/users_blocs/users/users_bloc.dart';
import '../../../../bloc/users_session_information_blocs/address_bloc/address_bloc.dart';
import '../../../../models/users_models/address.dart';
import '../../../../services/api_services/user_service/user_service.dart';
import '../../../../widgets/logic_widgets/user_widgets/addresses/helpers/address_dialogs.dart';
import '../../../../widgets/web/scaffold_web.dart';

class ConfirmAddressWebPage extends StatefulWidget {
  const ConfirmAddressWebPage({super.key});

  @override
  State<ConfirmAddressWebPage> createState() => _ConfirmAddressWebPageState();
}

class _ConfirmAddressWebPageState extends State<ConfirmAddressWebPage> {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['MAPS_API_KEY'];
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    return WebScaffold(
      userType: UserType.customer,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
            builder: (context, state) {
              if (state.selectedPlace == null) {
                return Center(child: Text("Selected place not found"));
              }
              
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(width: 8),
                            Text(
                              AddressStrings.addressDetails,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        
                        // Main content in two columns
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column - Map
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AddressStrings.address,
                                      style: TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      state.selectedPlace!.formattedAddress,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    SizedBox(height: 16),
                                    
                                    // Map container
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                'https://maps.googleapis.com/maps/api/staticmap?center=${state.selectedPlace!.geometry.location.lat},${state.selectedPlace!.geometry.location.lng}&zoom=16&size=800x600&scale=2&markers=color:red%7C${state.selectedPlace!.geometry.location.lat},${state.selectedPlace!.geometry.location.lng}&key=$apiKey',
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / 
                                                            loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Center(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                                                        SizedBox(height: 16),
                                                        Text('Error cargando el mapa'),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              Positioned(
                                                bottom: 16,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: ElevatedButton.icon(
                                                    icon: Icon(Icons.edit_location_alt),
                                                    label: Text(AddressStrings.adjustLocation),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue,
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 20, 
                                                        vertical: 12
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      handleWaitGpsStatus(context, () {
                                                        if (handleGpsAnswer(context, gpsBloc)) {
                                                          Navigator.pushReplacementNamed(
                                                              context, 'map_address');
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(width: 24),
                              
                              // Right column - Form fields
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AddressStrings.labelAddressInstruction,
                                      style: TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    TextFormField(
                                      controller: labelController,
                                      decoration: InputDecoration(
                                        labelText: AddressStrings.labelAddress,
                                        hintText: AddressStrings.hintAddress,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    
                                    Text(
                                      AddressStrings.detailsAddressInstruction,
                                      style: TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    TextFormField(
                                      controller: detailsController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: AddressStrings.labelDetails,
                                        hintText: AddressStrings.hintDetails,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    
                                    Spacer(),
                                    
                                    // Save button
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () => _saveAddress(context, state),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(200, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(AddressStrings.saveAddress),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _saveAddress(BuildContext context, SearchPlacesState state) async {
    if (labelController.text.isEmpty || detailsController.text.isEmpty) {
      showErrorDialog(context);
      return;
    }
    
    final addressBloc = BlocProvider.of<AddressBloc>(context);
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);
    final userId = BlocProvider.of<UsersBloc>(context).state.sessionUser!.id;

    final Future<Address?> address = UserService.createUserAddress(
      userId,
      labelController.text,
      state.selectedPlace!.formattedAddress,
      detailsController.text,
      state.selectedPlace!.geometry.location.lat,
      state.selectedPlace!.geometry.location.lng
    );

    address.then((createdAddress) {
      if (createdAddress != null) {
        addressBloc.add(AddAddress(
          id: createdAddress.id,
          name: createdAddress.name,
          address: createdAddress.address,
          details: createdAddress.details,
          latitude: createdAddress.latitude,
          longitude: createdAddress.longitude,
        ));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Center(
                child: Text(
                  AddressStrings.addressCreated,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.blue, size: 50),
                  SizedBox(height: 16),
                  Text(AddressStrings.successAddressCreation),
                ],
              ),
            );
          },
        );

        Future.delayed(Duration(seconds: 2), () {
          searchBloc.add(OnClearSelectedPlaceEvent());
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      }
    });
  }
}