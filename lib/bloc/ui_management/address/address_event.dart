part of 'address_bloc.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object> get props => [];
}

class AddAddress extends AddressEvent {
  final String name;
  final String address;
  final String details;
  final LatLng location;

  const AddAddress({
    required this.name,
    required this.address,
    required this.details,
    required this.location,
  });

  @override
  List<Object> get props => [name, address, details, location];
}

class EditAddress extends AddressEvent {
  final int index;
  final String name;
  final String details;

  const EditAddress({
    required this.index,
    required this.name,
    required this.details,
  });

  @override
  List<Object> get props => [index, name, details];
}

class DeleteAddress extends AddressEvent {
  final int index;

  const DeleteAddress({required this.index});

  @override
  List<Object> get props => [index];
}
