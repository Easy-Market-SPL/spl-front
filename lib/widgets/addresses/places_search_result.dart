import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

import '../../bloc/ui_management/search_places/search_places_bloc.dart';
import '../../models/ui/google/places_google_response.dart';
import '../../utils/strings/address_strings.dart';

class PlacesSearchResults extends StatelessWidget {
  final bool isSearching;

  const PlacesSearchResults({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        if (state.googlePlaces == null) {
          return SizedBox(
            child: CustomLoading(),
          );
        }

        // Show loading indicator if searching, else show nothing
        if (isSearching && state.googlePlaces!.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (state.googlePlaces!.isEmpty && !isSearching) {
            return SizedBox(); // If not searching, show nothing
          } else {
            // Show results
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.googlePlaces!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      AddressStrings.searchResults,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.googlePlaces!.length,
                  itemBuilder: (context, index) {
                    final place = state.googlePlaces![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text(
                          place.formattedAddress
                              .split(',')
                              .sublist(0)
                              .join(','),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          place.formattedAddress
                              .split(',')
                              .sublist(1)
                              .join(','),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        onTap: () {
                          _selectPlace(context, place);
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          }
        }
      },
    );
  }

  void _selectPlace(BuildContext context, Result place) {
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);
    searchBloc.getSelectedPlace(place);
    Navigator.popAndPushNamed(context, 'confirm_address');
  }
}
