import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/logic/address.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressState(addresses: [])) {
    on<AddAddress>((event, emit) {
      final newAddress = Address(
        id: event.id,
        name: event.name,
        address: event.address,
        details: event.details,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      final updatedAddresses = List<Address>.from(state.addresses)
        ..add(newAddress);
      emit(state.copyWith(addresses: updatedAddresses));
    });

    on<EditAddress>((event, emit) {
      int index =
          state.addresses.indexWhere((address) => address.id == event.id);

      final updatedAddress = Address(
        id: event.id,
        name: event.name,
        address: event.address,
        details: event.details,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      final updatedAddresses = List<Address>.from(state.addresses);
      updatedAddresses[index] = updatedAddress;
      emit(state.copyWith(addresses: updatedAddresses));
    });

    on<DeleteAddress>((event, emit) {
      final updatedAddresses = List<Address>.from(state.addresses);
      int index =
          updatedAddresses.indexWhere((address) => address.id == event.id);
      updatedAddresses.removeAt(index);
      emit(state.copyWith(addresses: updatedAddresses));
    });
  }
}
