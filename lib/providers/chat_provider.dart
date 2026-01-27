import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_services.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<MessageModel> _messages = [];
  List<UserModel> _users = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> sendMessage({required String receiverId, required String message, String? imagePath}) async {
    try {
      await _chatService.sendMessage(receiverId: receiverId, message: message, imagePath: imagePath);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<MessageModel>> getChatStream(String otherUserId) {
    return _chatService.getChatStream(otherUserId);
  }

  Future<List<UserModel>> getAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _chatService.getAllUsers();
      return _users;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
