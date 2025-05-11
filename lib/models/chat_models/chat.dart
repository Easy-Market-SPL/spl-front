class Chat {
  final String id;
  final String name;
  final String message;
  final String date;
  final String time;
  String? sender;

  Chat({
    required this.id, 
    required this.name, 
    required this.message, 
    required this.date, 
    required this.time,
    this.sender,
  });
}