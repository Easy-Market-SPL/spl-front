import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc()
      : super(AddressState(addresses: [
          Address(
            name: 'Casa Principal',
            address: 'Calle 26 # 92-32',
            details: 'Casa con jardín grande',
            location: LatLng(4.6097100, -74.0817500), // Coordenadas de Bogotá
          ),
          Address(
            name: 'Oficina Central',
            address: 'Calle 13 # 52-21',
            details: 'Oficina corporativa principal',
            location: LatLng(4.6097100, -74.0817500), // Coordenadas de Bogotá
          ),
          Address(
            name: 'Centro Comercial Andino',
            address: 'Carrera 11 # 82-20',
            details: 'Centro comercial con tiendas de lujo',
            location: LatLng(4.663428, -74.045435), // Coordenadas de Bogotá
          ),
        ])) {
    on<AddAddress>((event, emit) {
      final newAddress = Address(
        name: event.name,
        address: event.address,
        details: event.details,
        location: event.location,
      );
      final updatedAddresses = List<Address>.from(state.addresses)
        ..add(newAddress);
      emit(state.copyWith(addresses: updatedAddresses));
    });

    on<EditAddress>((event, emit) {
      final updatedAddress = Address(
        name: event.name,
        address: state.addresses[event.index].address,
        details: event.details,
        location: state.addresses[event.index].location,
      );
      final updatedAddresses = List<Address>.from(state.addresses);
      updatedAddresses[event.index] = updatedAddress;
      emit(state.copyWith(addresses: updatedAddresses));
    });

    on<DeleteAddress>((event, emit) {
      final updatedAddresses = List<Address>.from(state.addresses);
      updatedAddresses.removeAt(event.index);
      emit(state.copyWith(addresses: updatedAddresses));
    });
  }
}
