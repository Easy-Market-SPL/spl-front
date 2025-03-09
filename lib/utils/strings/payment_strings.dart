class PaymentStrings {
  static const confirmDeleteCard = 'Confirmar eliminación';
  static const cancelDelete = 'Cancelar';
  static const delete = 'Eliminar';

  static deleteAnnouncement(String lastFourDigits) =>
      '¿Está seguro de eliminar la tarjeta de pago que finaliza en $lastFourDigits?';
}
