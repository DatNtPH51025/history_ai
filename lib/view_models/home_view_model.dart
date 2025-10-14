import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/services/firebase_chat_service.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/models/home_state.dart';
import 'package:history_ai/models/message.dart';
import 'package:history_ai/models/ai_history_model.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  final HistoryAI _aiModel = HistoryAI();
  final FirebaseChatService _chatService = FirebaseChatService();
  final StreamController<String> _responseStreamController =
  StreamController<String>.broadcast();

  Stream<String> get responseStream => _responseStreamController.stream;

  HomeViewModel()
      : super(HomeState(
    messages: [],
    chatHistories: [],
    isLoading: false,
    controller: TextEditingController(),
  ));

  /// Load lại tin nhắn từ lịch sử
  void loadChat(String chatId) {
    final chat = state.chatHistories.firstWhere(
          (c) => c.id == chatId,
      orElse: () => ChatHistory(
        id: '0',
        title: 'Mới',
        lastMessage: '',
        messages: [],
      ),
    );
    state = state.copyWith(messages: chat.messages);
  }

  /// Thêm message mới và cập nhật lịch sử chat
  void addMessageToHistory(Message message) {
    final chatId = 'default_chat'; // Tạm thời 1 cuộc chat
    final existing = state.chatHistories.where((c) => c.id == chatId);
    if (existing.isEmpty) {
      state = state.copyWith(chatHistories: [
        ...state.chatHistories,
        ChatHistory(
          id: chatId,
          title: 'Cuộc chat',
          lastMessage: message.text,
          messages: [...state.messages], // dùng messages hiện tại
        ),
      ]);
    } else {
      final updatedHistory = state.chatHistories.map((c) {
        if (c.id == chatId) {
          return ChatHistory(
            id: c.id,
            title: c.title,
            lastMessage: message.text,
            messages: [...state.messages], // dùng messages hiện tại
          );
        }
        return c;
      }).toList();
      state = state.copyWith(chatHistories: updatedHistory);
    }
  }


  /// Gọi AI
  Future<void> callAI() async {
    final userMessage = state.controller.text.trim();
    if (userMessage.isEmpty) return;

    final userMsg = Message(text: userMessage, isUser: true);

    // ✅ Thêm user message vào state
    state = state.copyWith(
      messages: [...state.messages, userMsg, Message(text: "Đang trả lời...", isUser: false)],
      isLoading: true,
    );

    await _chatService.saveMessage(userMsg); // lưu user msg

    try {
      final responseText = await _aiModel.ask(userMessage);
      final aiMsg = Message(text: responseText, isUser: false);

      // 🔥 Ghi đè placeholder bằng AI response
      final replaced = [...state.messages];
      replaced[replaced.length - 1] = aiMsg;
      state = state.copyWith(messages: replaced);

      addMessageToHistory(aiMsg); // lưu AI msg vào lịch sử
      await _chatService.saveMessage(aiMsg);

    } catch (e) {
      final errorMsg = Message(text: "Lỗi: ${e.toString()}", isUser: false);
      final replaced = [...state.messages];
      replaced[replaced.length - 1] = errorMsg;
      state = state.copyWith(messages: replaced);
      await _chatService.saveMessage(errorMsg);
    } finally {
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
