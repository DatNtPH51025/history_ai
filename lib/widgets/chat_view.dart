import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/view_models/home_view_model.dart';
import 'package:history_ai/widgets/message_bubble.dart';
import 'package:history_ai/widgets/message_input_bar.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    // Lắng nghe sự thay đổi của danh sách tin nhắn để tự động cuộn
    ref.listen<int>(homeViewModelProvider.select((s) => s.messages.length), (previous, next) {
      if (next > (previous ?? 0)) { // Chỉ cuộn khi có tin nhắn mới
        Future.delayed(const Duration(milliseconds: 50), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return MessageBubble(
                message: message,
                isUser: message.isUser,
              );
            },
          ),
        ),
        MessageInputBar(
          controller: state.controller,
          isLoading: state.isLoading,
          onSend: () {
            final text = state.controller.text.trim();
            if (text.isNotEmpty) {
              viewModel.callAI();
            }
          },
        ),
      ],
    );
  }
}
