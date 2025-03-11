class AddressPaymentModel {
  final String city;
  final String country;
  final String line1;
  final String line2;
  final String state;
  final String postalCode;

  AddressPaymentModel({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.state,
    required this.postalCode,
  });
}

AddressPaymentModel genericPaymentAddress() {
  return AddressPaymentModel(
    city: 'Bogota',
    line1: 'Calle 22A #52 - 79',
    line2: 'Torre 3 - Apto 212',
    country: 'Colombia',
    postalCode: '110221',
    state: 'Cundinamarca',
  );
}
