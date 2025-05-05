import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/widgets/helpers/custom_loading.dart';

import '../../../../bloc/ui_blocs/search_places_bloc/search_places_bloc.dart';
import '../../../../models/helpers/ui_models/google/places_google_response.dart';

class PlacesSearchResults extends StatefulWidget {
  final bool isSearching;

  const PlacesSearchResults({super.key, required this.isSearching});

  @override
  State<PlacesSearchResults> createState() => _PlacesSearchResultsState();
}

class _PlacesSearchResultsState extends State<PlacesSearchResults> {
  @override
  void initState() {
    super.initState();

    final searchPlacesBloc = context.read<SearchPlacesBloc>();
    searchPlacesBloc.add(OnClearSelectedPlaceEvent());
  }

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
        if (widget.isSearching && state.googlePlaces!.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (state.googlePlaces!.isEmpty && !widget.isSearching) {
            return SizedBox.shrink();
          } else {
            // Show results
            return SingleChildScrollView(
              child: ListView.builder(
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
                        place.formattedAddress.split(',').sublist(0).join(','),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        place.formattedAddress.split(',').sublist(1).join(','),
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
