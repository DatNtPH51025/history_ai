import '../../domain/entities/chat_history.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> saveMessage(String chatId, Message message) {
    return _remoteDataSource.saveMessage(chatId, message);
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    return _remoteDataSource.getMessages(chatId);
  }

  @override
  Future<void> clearChat(String chatId) {
    return _remoteDataSource.clearChat(chatId);
  }

  @override
  Future<void> createChatRoom(String userId, String chatId, String title) {
    return _remoteDataSource.createChatRoom(userId, chatId, title);
  }

  @override
  Stream<List<ChatHistory>> getChatHistories() {
    return _remoteDataSource.getChatHistories();
  }

  @override
  Future<void> renameChatRoom(String chatId, String newTitle) {
    return _remoteDataSource.renameChatRoom(chatId, newTitle);
  }

  @override
  Future<void> deleteChatRoom(String chatId) {
    return _remoteDataSource.deleteChatRoom(chatId);
  }

  @override
  Future<String> askAI(String question, List<Message> history) {
    return _remoteDataSource.askAI(question, history);
  }
}
