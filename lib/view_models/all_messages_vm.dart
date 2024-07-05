import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:task_management_app/models/message.dart';
import 'package:task_management_app/repositories/message_repo.dart';

class AllMessagesViewModel with ChangeNotifier {
  final MessageRepository _messageRepository;
  StreamSubscription<List<Message>>? _messagesSubscription;

  List<Message> _messages = [];
  List<Message> get messages => _messages;
  String _serverId;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  AllMessagesViewModel(String serverId,{MessageRepository? messageRepository})
      : _serverId = serverId, _messageRepository = messageRepository ?? MessageRepository() {
    _initialize();
  }

  void _initialize() {
    _messagesSubscription = _messageRepository.streamMessages(_serverId).listen(
      (messages) {
        _isInitializing = false;
        _messages = messages;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  void updateServerId(String newServerId) {
    if (newServerId != _serverId) {
      _messagesSubscription?.cancel();
      _serverId = newServerId;
      _isInitializing = true; 
      notifyListeners(); 
      _initialize();
    }
  }

  Future<String> addMessage(Message newMessage) async {
    return await _messageRepository.addMessage(_serverId,newMessage);
  }

  Future<void> deleteMessage(String messageId) async {
    await _messageRepository.deleteMessage(_serverId,messageId);
  }
}
