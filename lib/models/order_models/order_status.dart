class OrderStatus {
  final String status;
  final DateTime startDate;
  DateTime? endDate;
  String? notes;

  OrderStatus({
    required this.status,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      status: json["status"],
      startDate: DateTime.parse(json["startDate"]),
      endDate:
          (json["endDate"] == null) ? null : DateTime.parse(json["endDate"]),
      notes: json["notes"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "notes": notes,
      };
}
