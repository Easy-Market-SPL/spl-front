import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/users_models/address.dart';
import '../../../services/api_services/user_service/user_service.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressState(addresses: const [])) {
    on<LoadAddresses>((event, emit) async {
      try {
        final addresses = await UserService.getUserAddresses(event.userId);
        if (addresses == null || addresses.isEmpty) {
          emit(state.copyWith(addresses: []));
        } else {
          emit(state.copyWith(addresses: addresses));
        }
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

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

    on<EditAddress>((event, emit) async {
      int index =
          state.addresses.indexWhere((address) => address.id == event.id);

      // Make the call to the API to update the address
      // If the call is successful, update the state

      await UserService.updateUserAddress(
        event.userId,
        Address(
          id: event.id,
          name: event.name,
          address: event.address,
          details: event.details,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      );

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

    on<DeleteAddress>((event, emit) async {
      await UserService.deleteUserAddress(event.userId, event.id);

      final updatedAddresses = List<Address>.from(state.addresses);
      int index =
          updatedAddresses.indexWhere((address) => address.id == event.id);
      updatedAddresses.removeAt(index);
      emit(state.copyWith(addresses: updatedAddresses));
    });
  }
}
