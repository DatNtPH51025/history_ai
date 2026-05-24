import '../entities/chat_history.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<void> saveMessage(String chatId, Message message);
  Stream<List<Message>> getMessages(String chatId);
  Future<void> clearChat(String chatId);
  Future<void> createChatRoom(String userId, String chatId, String title);
  Stream<List<ChatHistory>> getChatHistories();
  Future<void> renameChatRoom(String chatId, String newTitle);
  Future<void> deleteChatRoom(String chatId);
  Future<String> askAI(String question, List<Message> history);
}
