import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../repository/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  List<ChatMessage> messages = [];
  List<ChatUser> typingUsers = [];

  Timer? pollingTimer;
  Timer? typingTimer;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
    on<UpdateTyping>(_onUpdateTyping);

    // Start polling every 5 seconds
    pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(FetchMessages());
    });

    // Immediately fetch once
    add(FetchMessages());
  }

  Future<void> _onFetchMessages(
      FetchMessages event,
      Emitter<ChatState> emit,
      ) async {
    try {
      messages = await repository.fetchMessages();
      emit(ChatLoaded(
        messages: messages,
        typingUsers: List.from(typingUsers),
      ));
    } catch (e) {
      emit(ChatError("Failed to fetch messages"));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event,
      Emitter<ChatState> emit,
      ) async {
    try {
      final newMessage = await repository.sendMessage(event.text);
      messages.insert(0, newMessage);
      typingUsers.remove(repository.sender);
      emit(ChatLoaded(
        messages: messages,
        typingUsers: List.from(typingUsers),
      ));
    } catch (e) {

      print("e=>" + e.toString());
      emit(ChatError("Failed to send message"));
    }
  }

  void _onUpdateTyping(
      UpdateTyping event,
      Emitter<ChatState> emit,
      ) {
    final sender = repository.sender;

    if (event.isTyping && !typingUsers.contains(sender)) {
      // user started typing
      typingUsers.add(sender);
      emit(ChatLoaded(
        messages: messages,
        typingUsers: List.from(typingUsers),
      ));

      // cancel any previous timer
      typingTimer?.cancel();

      // after 2 seconds, dispatch a new event instead of calling emit here
      typingTimer = Timer(const Duration(seconds: 2), () {
        add(UpdateTyping(false)); // ✅ safe, no emit in Timer
      });
    } else if (!event.isTyping && typingUsers.contains(sender)) {
      // user stopped typing
      typingUsers.remove(sender);
      emit(ChatLoaded(
        messages: messages,
        typingUsers: List.from(typingUsers),
      ));
    }
  }

  @override
  Future<void> close() {
    pollingTimer?.cancel();
    typingTimer?.cancel();
    return super.close();
  }
}
