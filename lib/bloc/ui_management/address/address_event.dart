part of 'address_bloc.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object> get props => [];
}

class LoadAddresses extends AddressEvent {
  final String userId;
  const LoadAddresses(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddAddress extends AddressEvent {
  final int id;
  final String name;
  final String address;
  final String details;
  final double latitude;
  final double longitude;

  const AddAddress({
    required this.id,
    required this.name,
    required this.address,
    required this.details,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [id, name, address, details, latitude, longitude];
}

class EditAddress extends AddressEvent {
  final String userId;
  final int id;
  final String name;
  final String address;
  final String details;
  final double latitude;
  final double longitude;

  const EditAddress({
    required this.userId,
    required this.id,
    required this.name,
    required this.address,
    required this.details,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props =>
      [userId, id, name, address, details, latitude, longitude];
}

class DeleteAddress extends AddressEvent {
  final String userId;
  final int id;

  const DeleteAddress({required this.userId, required this.id});

  @override
  List<Object> get props => [userId, id];
}
