part of 'address_bloc.dart';

class AddressState extends Equatable {
  final List<Address> addresses;
  final bool isLoading;
  final String error;

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.error = '',
  });

  AddressState copyWith({
    List<Address>? addresses,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [addresses, isLoading, error];
}
