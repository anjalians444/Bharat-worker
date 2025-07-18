import 'package:flutter/material.dart';
import '../services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatProvider with ChangeNotifier {
  final ChatServices chatServices;

  ChatProvider({required this.chatServices});

  Future<void> sendMessage({
    required String content,
    required String type,
    required String groupChatId,
    required String currentUserId,
    required String receiverId,
    String filename = '',
    String seen = '0',
    String bookingId = '',
    TextEditingController? controller,
    FocusNode? focusNode,
    String status = '0', // <-- Add status param, default to '0' (sent)
    String? replyTo, // <-- Add replyTo param
    // Optionally pass scrollController if you want to scroll after sending
  }) async {
    if (content.trim().isEmpty) return;
    String lastSeenState = DateFormat.MMMd().format(DateTime.now()).toString();
     chatServices.sendChatMessage(
      content,
      type,
      groupChatId,
      currentUserId,
      receiverId,
      filename,
      seen,
      Timestamp.now(),
      lastSeenState,
      "1", // TODO: Add logic for first message if needed
      "0",
      status, // <-- Pass status
      replyTo, // <-- Pass replyTo
    );
    controller?.clear();
    focusNode?.unfocus();
    chatServices.lastUpdateMsg(groupChatId, currentUserId);
   // chatServices.seeMsg(groupChatId, currentUserId);
    chatServices.decrementCount(currentUserId);
    // Optionally: scrollController?.animateTo(...)
    notifyListeners();
  }

  /// Ensures a welcome message is present in a new chat room if there are no messages yet.
  Future<void> ensureWelcomeMessage({
    required String groupChatId,
    required String receiverId,
    String systemUserId = 'system',
    String welcomeText = 'Welcome to the chat! How can we help you today?',
  }) async {
    final messagesSnapshot = await chatServices.firebaseFirestore
        .collection('chat')
        .doc(groupChatId)
        .collection('Message')
        .limit(1)
        .get();
    if (messagesSnapshot.docs.isEmpty) {
      chatServices.sendChatMessage(
        welcomeText,
        'text',
        groupChatId,
        systemUserId,
        receiverId,
        '',
        '1',
        Timestamp.now(),
        DateFormat.MMMd().format(DateTime.now()).toString(),
        '1',
        '0',
        '1', // <-- status delivered for system message
      );
    }
  }
} 