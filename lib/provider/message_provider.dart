import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/api_paths.dart';

class MessageProvider extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  final TextEditingController messageController = TextEditingController();

  // User list related properties
  List<BookedCustomer> _userList = [];
  bool _isLoading = false;
  String? _error;

  List<MessageModel> get messages => List.unmodifiable(_messages);
  List<BookedCustomer> get userList => List.unmodifiable(_userList);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch user list from API
  Future<void> fetchUserList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().get(ApiPaths.userList);

      if (response != null && response['success'] == true) {
        final userListResponse = UserListResponse.fromJson(response);
        _userList = userListResponse.data.bookedCustomer;
        _error = null;
      } else {
        _error = response?['message'] ?? 'Failed to fetch user list';
        _userList = [];
      }
    } catch (e) {
      _error = 'Error fetching user list: $e';
      _userList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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