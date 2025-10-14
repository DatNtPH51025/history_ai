import 'package:history_ai/models/message.dart';

class ChatHistory {
  final String id;
  final String title;
  final String lastMessage;
  final List<Message> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.messages,
  });
}


