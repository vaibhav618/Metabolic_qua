import 'package:dash_chat_2/dash_chat_2.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final List<ChatUser> typingUsers;

  ChatLoaded({
    required this.messages,
    required this.typingUsers,
  });
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
