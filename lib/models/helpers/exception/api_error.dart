/// Represents the error object returned by the backend.
/// Example of JSON response:
/// {
///   "message": "Order with ID X not found",
///   "timestamp": "2025-04-15T00:22:29.740573667Z",
///   "status": 404,
///   "reason": "Not Found"
/// }
///
class ApiError {
  final String message;
  final String? reason;
  final int? status;
  final String? timestamp;

  ApiError({
    required this.message,
    this.reason,
    this.status,
    this.timestamp,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        message: json["message"] ?? "Unknown error",
        reason: json["reason"],
        status: json["status"],
        timestamp: json["timestamp"],
      );

  @override
  String toString() => message;
}
