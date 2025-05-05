class OrderStrings {
  static const String orderTrackingTittle = 'Seguimiento de pedido';
  static const String ordersTitle = 'Órdenes';
  static const String ordersTitleDelivery = 'Órdenes Disponibles';
  static const String searchOrdersHint = 'Buscar órdenes...';
  static const String statusConfirmed = 'Confirmado';
  static const String statusPreparing = 'Preparando';
  static const String statusOnTheWay = 'En camino';
  static const String statusDelivered = 'Entregada';
  static const String dateRange = 'Fechas';
  static const String orderDetailsTitle = 'Detalles de la orden';
  static const String orderNumber = 'Número de orden';
  static const String idOrder = 'ID de Orden';
  static const String deliveryIn = 'Hacía';
  static const String noLocation = 'Dirección Mapa';
  static const String orderDate = 'Fecha';
  static const String orderProductCount = 'Número de productos';
  static const String viewProducts = 'Ver productos';
  static const String orderTotal = 'Total';
  static const String customerDetailsTitle = 'Detalles del cliente';
  static const String customerName = 'Nombre de cliente';
  static const String deliveryAddress = 'Dirección de entrega';
  static const String deliveryDetailsTitle = 'Detalles del domiciliario';
  static const String deliveryPersonName = 'Nombre del repartidor';
  static const String noDeliveryPersonAssigned = 'Sin repartidor asignado';
  static const String shippingCompanyTitle = 'Empresa de envío';
  static const String selectedShippingCompany = 'Empresa seleccionada';
  static const String shippingCompany = 'Empresa transportista';
  static const String errorLoadingOrderStatus =
      'Error al cargar el estado de la orden';
  static const String filtersTitle = 'Filtros';
  static const String sortBy = 'Ordenar por:';
  static const String filterByStatus = 'Filtrar por estado:';
  static const String showByStatus = 'Mostrar por estado';
  static const String searchByDate = 'Buscar por fecha:';
  static const String selectDateRange = 'Seleccionar rango de fechas';
  static const String mostRecent = 'Más recientes';
  static const String leastRecent = 'Menos recientes';
  static const String mostItems = 'Más items';
  static const String clear = 'Limpiar';
  static const String confirm = 'Confirmar';
  static const String date = 'Fecha';
  static const String client = 'Cliente';
  static const String status = 'Estado';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusOnTheWay = 'on the way';
  static const String orderStatusDelivered = 'delivered';
  static const String items = 'Items';
  static const String takeOrder = 'Tomar Orden';
  static const String viewOrder = 'Ver orden';
  static const String confirmStatusChangeTitle = 'Confirmar cambio de estado';
  static const String cancel = 'Cancelar';
  static const String accept = 'Aceptar';
  static const String orderConfirmed = 'Orden Confirmada';
  static const String orderConfirmedDescription =
      'Tu orden ha sido procesada correctamente';
  static const String notConfirmed = 'Sin confirmar';
  static const String notConfirmedDescription =
      'Tu orden aún no ha sido aceptada';
  static const String preparingOrder = 'Preparando la Orden';
  static const String preparingOrderDescription =
      'Tu orden está siendo preparada para su entrega';
  static const String notPrepared = 'Sin preparar';
  static const String notPreparedDescription =
      'Tu orden aún no se ha procesado';
  static const String onTheWay = 'En camino';
  static const String onTheWayDescription =
      'La orden se encuentra en camino hacía el destino';
  static const String notOnTheWay = 'Sin salir';
  static const String notOnTheWayDescription =
      'Tu orden no está lista para partir';
  static const String delivered = 'Entregada';
  static const String deliveredDescription = 'La orden ha sido entregada';
  static const String notDelivered = 'Sin entregar';
  static const String notDeliveredDescription =
      'Tu orden aún no ha sido entregada';
  static const String estimatedDeliveryDate = 'Fecha de entrega estimada';
  static const String selectShippingCompany = 'Seleccionar Empresa de Envío';
  static const String productsInOrder = 'Productos en esta orden';
  static const String modifyOrderStatus = 'Modificar estado de la orden';
  static const orderElements = 'Elementos de la Orden';
  static const addressDelivery = 'Dirección de Entrega';
  static const notAvailable = 'No disponible';
  static const deliverAt = 'Entregar en';

  static String showDateRangeString(String startDate, String endDate) {
    return 'Entre: $startDate - $endDate';
  }

  static String confirmStatusChangeContent(String status) {
    return '¿Estás seguro de que deseas cambiar el estado de la orden a "$status"?';
  }

  static String estimatedDeliveryMinutes(int minutes) {
    return 'Tiempo estimado: $minutes min';
  }

  static String estimatedDistanceKms(double distance) {
    // Return the distance in kilometers with two decimals
    return 'Distancia: ${distance.toStringAsFixed(2)} km';
  }

  static String estimatedDistanceMeters(double distance) {
    // Return the distance in meters without decimals
    return 'Distancia: ${distance.toInt()} metros';
  }

  static String nameOrder(String? clientName) {
    return 'A nombre de: ${clientName ?? "Desconocido"}';
  }

  static String orderNumberString(String? orderNumber) {
    return 'Orden #${orderNumber ?? "Desconocido"}';
  }
}
