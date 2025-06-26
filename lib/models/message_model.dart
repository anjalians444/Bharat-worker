class MessageModel {
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;

  MessageModel({
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
  });
} 