import 'package:flutter/cupertino.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/models/message.dart';

class HomeState {
  final List<Message> messages;
  final List<ChatHistory> chatHistories; // thêm đây
  final TextEditingController controller;
  final bool isLoading;

  HomeState({
    required this.messages,
    required this.chatHistories,
    required this.controller,
    required this.isLoading,
  });

  HomeState copyWith({
    List<Message>? messages,
    List<ChatHistory>? chatHistories,
    TextEditingController? controller,
    bool? isLoading,
  }) {
    return HomeState(
      messages: messages ?? this.messages,
      chatHistories: chatHistories ?? this.chatHistories,
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}