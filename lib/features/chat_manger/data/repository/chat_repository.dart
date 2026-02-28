import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';

class ChatRepository {
  final String fetchUrl = "https://humorstech.com/humors_app/app_final/dieticianapp/api/get_messages.php";
  final String insertUrl = "https://humorstech.com/humors_app/app_final/dieticianapp/api/insert_message.php";

  final ChatUser sender;
  final ChatUser receiver;

  ChatRepository({required this.sender, required this.receiver});

  Future<List<ChatMessage>> fetchMessages() async {
    final response = await http.post(Uri.parse(fetchUrl), body: {
      'id_user1': sender.id,
      'id_user2': receiver.id,
    });

    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List).map((msg) {
        return ChatMessage(
          text: msg['txt_message'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(msg['timestamp']) * 1000),
          user: msg['id_sender'] == sender.id ? sender : receiver,
        );
      }).toList().reversed.toList();
    } else {
      throw Exception("Failed to fetch messages");
    }
  }

  Future<ChatMessage> sendMessage(String messageText) async {
    final response = await http.post(Uri.parse(insertUrl), body: {
      'type': 'all',
      'id_sender': sender.id,
      'id_receiver': receiver.id,
      'message_type': 'text',
      'txt_message': messageText,
    });

    final data = jsonDecode(response.body);

    print(response.body);
    if (data['success']) {
      final inserted = data['data'];
      return ChatMessage(
        text: inserted['txt_message'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          int.parse(inserted['timestamp']) * 1000,
        ),
        user: sender,
      );
    } else {
      throw Exception("Failed to send message");
    }
  }
}
