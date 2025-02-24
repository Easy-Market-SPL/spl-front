import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/search_places/search_places_bloc.dart';

class ConfirmAddressPage extends StatefulWidget {
  const ConfirmAddressPage({super.key});

  @override
  State<ConfirmAddressPage> createState() => _ConfirmAddressPageState();
}

class _ConfirmAddressPageState extends State<ConfirmAddressPage> {
  @override
  Widget build(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchPlacesBloc>(context);
    return BlocBuilder<SearchPlacesBloc, SearchPlacesState>(
      builder: (context, state) {
        return Column(
          children: [
            Text(searchBloc.state.selectedPlace!.formattedAddress),
            Text(searchBloc.state.selectedPlace!.geometry.location.lat
                .toString()),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'add_address');
                },
                child: Text('Volver'))
          ],
        );
      },
    );
  }
}
