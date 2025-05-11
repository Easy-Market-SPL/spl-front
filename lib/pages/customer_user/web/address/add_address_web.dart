import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/models/helpers/intern_logic/user_type.dart';
import 'package:spl_front/pages/customer_user/profile_addresses/add_address.dart';
import 'package:spl_front/utils/strings/address_strings.dart';
import 'package:spl_front/utils/strings/map_strings.dart';

import '../../../../../bloc/location_management_bloc/gps_bloc/gps_bloc.dart';
import '../../../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import '../../../../../widgets/logic_widgets/user_widgets/addresses/places_search_result.dart';
import '../../../../../widgets/web/scaffold_web.dart';

class AddAddressWebPage extends StatefulWidget {
  const AddAddressWebPage({super.key});

  @override
  State<AddAddressWebPage> createState() => _AddAddressWebPageState();
}

class _AddAddressWebPageState extends State<AddAddressWebPage> {
  late SearchPlacesBloc searchPlacesBloc;
  bool isSearching = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchPlacesBloc = BlocProvider.of<SearchPlacesBloc>(context);
    searchPlacesBloc.emptyGooglePlaces();
    searchPlacesBloc.clearSelectedPlace();
  }

  @override
  Widget build(BuildContext context) {
    final gpsBloc = BlocProvider.of<GpsBloc>(context);

    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        return WebScaffold(
          userType: UserType.customer,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1000),
              child: Card(
                margin: EdgeInsets.all(32),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 16),
                          Text(
                            AddressStrings.addNewAddress,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: AddressStrings.searchAddress,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                style: TextStyle(fontSize: 16),
                                onChanged: (query) {
                                  setState(() {
                                    isSearching = query.isNotEmpty;
                                  });
                                  if (query.isNotEmpty) {
                                    searchPlacesBloc.getPlacesByGoogleQuery(query);
                                  }
                                },
                              ),
                            ),
                            if (searchController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    isSearching = false;
                                  });
                                  searchPlacesBloc.emptyGooglePlaces();
                                },
                              ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Search Options
                      InkWell(
                        onTap: () {
                          handleWaitGpsStatus(context, () {
                            if (handleGpsAnswer(context, gpsBloc)) {
                              Navigator.pushReplacementNamed(context, 'map_address');
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 16),
                              Text(
                                MapStrings.selectOnMap,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Search Results
                      Expanded(
                        child: isSearching 
                          ? PlacesSearchResults(isSearching: true)
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_searching, size: 100, color: Colors.grey[300]),
                                  SizedBox(height: 16),
                                  Text(
                                    "Busca una dirección",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}