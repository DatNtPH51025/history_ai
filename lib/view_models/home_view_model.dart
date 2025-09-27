import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/services/firebase_chat_service.dart';
import 'package:history_ai/models/message.dart';
import 'package:history_ai/models/ai_history_model.dart';

class HomeState {
  final List<Message> messages;
  final bool isLoading;
  final TextEditingController controller;

  HomeState({
    required this.messages,
    required this.isLoading,
    required this.controller,
  });

  HomeState copyWith({
    List<Message>? messages,
    bool? isLoading,
    TextEditingController? controller,
  }) {
    return HomeState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      controller: controller ?? this.controller,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final HistoryAI _aiModel = HistoryAI();
  final FirebaseChatService _chatService = FirebaseChatService(); // ✅ Firestore service
  final StreamController<String> _responseStreamController =
  StreamController<String>.broadcast();

  Stream<String> get responseStream => _responseStreamController.stream;

  HomeViewModel()
      : super(HomeState(
    messages: [],
    isLoading: false,
    controller: TextEditingController(),
  ));

  /// 📌 Gọi AI để xử lý câu hỏi lịch sử
  Future<void> callAI() async {
    final userMessage = state.controller.text.trim();
    if (userMessage.isEmpty) return;

    final userMsg = Message(text: userMessage, isUser: true);

    // Thêm user message + placeholder
    final updatedMessages = [...state.messages, userMsg, Message(text: "Đang trả lời...", isUser: false)];
    state = state.copyWith(messages: updatedMessages, isLoading: true);
    await _chatService.saveMessage(userMsg);

    try {
      final responseText = await _aiModel.ask(userMessage);
      final aiMsg = Message(text: responseText, isUser: false);

      // 🔥 Ghi đè placeholder cuối bằng AI response
      final replaced = [...state.messages];
      replaced[replaced.length - 1] = aiMsg;

      state = state.copyWith(messages: replaced);
      await _chatService.saveMessage(aiMsg);

    } catch (e) {
      final errorMsg = Message(text: "Lỗi: ${e.toString()}", isUser: false);

      final replaced = [...state.messages];
      replaced[replaced.length - 1] = errorMsg;

      state = state.copyWith(messages: replaced);
      await _chatService.saveMessage(errorMsg);
    } finally {
      // 🔄 luôn reset loading và clear input
      state = state.copyWith(isLoading: false);
      state.controller.clear();
    }
  }


  @override
  void dispose() {
    _responseStreamController.close();
    super.dispose();
  }
}

// Provider Riverpod
final homeViewModelProvider =
StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});
