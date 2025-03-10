class PaymentStrings {
  static const confirmDeleteCard = 'Confirmar eliminación';
  static const cancelDelete = 'Cancelar';
  static const delete = 'Eliminar';
  static const processingPayment = 'Procesando pago';
  static const waitAMoment = 'Espere un momento por favor';
  static const paymentTittle = 'Confirma tu pago';
  static const total = 'Total';
  static const selectCard = 'Seleccionar tarjeta';
  static const confirmPaymentAssertion =
      'Tu pago se ha procesado correctamente';
  static const accept = 'Aceptar';
  static const successPayment = 'Pago exitoso';
  static const errorInPayment = 'Error en el pago';
  static const unknownError = 'Ocurrió un error inesperado';
  static const selectCardBeforePayment =
      'Por favor, seleccione una tarjeta antes de proceder con el pago.';
  static deleteAnnouncement(String lastFourDigits) =>
      '¿Está seguro de eliminar la tarjeta de pago que finaliza en $lastFourDigits?';
}
