import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/message.dart';
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
  final HistoryAI _aiModel = HistoryAI(); // ✅ Đổi sang HistoryAI
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

    // Thêm câu hỏi người dùng
    state = state.copyWith(
      messages: [
        ...state.messages,
        Message(text: userMessage, isUser: true),
        Message(text: "...", isUser: false),
      ],
      isLoading: true,
    );

    try {
      final responseText = await _aiModel.ask(userMessage);

      // Thêm trả lời AI
      _responseStreamController.add(responseText);
      state = state.copyWith(
        messages: [
          ...state.messages.sublist(0, state.messages.length - 1),
          Message(text: responseText, isUser: false),
        ],
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          Message(text: "Lỗi: ${e.toString()}", isUser: false),
        ],
      );
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
