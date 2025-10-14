import 'package:flutter/cupertino.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/models/message.dart';

class HomeState {
  final List<Message> messages;
  final List<ChatHistory> chatHistories;
  final bool isLoading;
  final TextEditingController controller;
  final String activeChatId; // thêm chatId hiện tại

  HomeState({
    required this.messages,
    required this.chatHistories,
    required this.isLoading,
    required this.controller,
    this.activeChatId = '',
  });

  HomeState copyWith({
    List<Message>? messages,
    List<ChatHistory>? chatHistories,
    bool? isLoading,
    TextEditingController? controller,
    String? activeChatId,
  }) {
    return HomeState(
      messages: messages ?? this.messages,
      chatHistories: chatHistories ?? this.chatHistories,
      isLoading: isLoading ?? this.isLoading,
      controller: controller ?? this.controller,
      activeChatId: activeChatId ?? this.activeChatId,
    );
  }
  factory HomeState.initial() {
    return HomeState(
      messages: [],
      chatHistories: [],
      isLoading: false,
      controller: TextEditingController(),
      activeChatId: '',
    );
  }
}
