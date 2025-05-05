class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final String date;
  final String? fileUrl;
  final MessageType type;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.date,
    this.fileUrl,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image, video }