import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageProvider extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  final TextEditingController messageController = TextEditingController();

  List<MessageModel> get messages => List.unmodifiable(_messages);

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _messages.add(MessageModel(
      text: text.trim(),
      timestamp: DateTime.now(),
      isSentByMe: true,
    ));
    messageController.clear();
    notifyListeners();
  }

  void receiveMessage(String text) {
    _messages.add(MessageModel(
      text: text.trim(),
      timestamp: DateTime.now(),
      isSentByMe: false,
    ));
    notifyListeners();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
} 