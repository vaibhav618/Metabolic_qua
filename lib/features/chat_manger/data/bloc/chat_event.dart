abstract class ChatEvent {}

class FetchMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;

  SendMessage(this.text);
}

class UpdateTyping extends ChatEvent {
  final bool isTyping;

  UpdateTyping(this.isTyping);
}
