import '../../../domain/entities/chat_history.dart';
import '../../../domain/entities/message.dart';

class ChatState {
  final List<Message> messages;
  final List<ChatHistory> chatHistories;
  final bool isLoading;
  final String activeChatId;
  final String? errorMessage;

  const ChatState({
    required this.messages,
    required this.chatHistories,
    required this.isLoading,
    this.activeChatId = '',
    this.errorMessage,
  });

  factory ChatState.initial() {
    return const ChatState(
      messages: [],
      chatHistories: [],
      isLoading: false,
      activeChatId: '',
    );
  }

  ChatState copyWith({
    List<Message>? messages,
    List<ChatHistory>? chatHistories,
    bool? isLoading,
    String? activeChatId,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      chatHistories: chatHistories ?? this.chatHistories,
      isLoading: isLoading ?? this.isLoading,
      activeChatId: activeChatId ?? this.activeChatId,
      errorMessage: errorMessage,
    );
  }
}
