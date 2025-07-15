import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/message.dart';
import 'package:history_ai/themeNotifier.dart';
import 'package:history_ai/view_models/home_view_model.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/gpt-robot.png'),
                const SizedBox(width: 10),
                Text('Gemini', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            GestureDetector(
              child: (currentTheme == ThemeMode.dark)
                  ? Icon(Icons.light_mode,
                      color: Theme.of(context).colorScheme.secondary)
                  : Icon(Icons.dark_mode,
                      color: Theme.of(context).colorScheme.primary),
              onTap: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
          // Thêm StreamBuilder để xử lý streaming response
          StreamBuilder<String>(
            stream: viewModel.responseStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Cập nhật tin nhắn cuối cùng với nội dung streaming
                final messages = [...state.messages];
                if (messages.isNotEmpty && !messages.last.isUser) {
                  messages[messages.length - 1] = Message(
                    text: snapshot.data!,
                    isUser: false,
                  );
                  return Container(); // Ẩn widget thực tế vì ListView đã xử lý
                }
              }
              return Container();
            },
          ),
          // Phần input message (giữ nguyên)
          MessageInputBar(
            controller: state.controller,
            isLoading: state.isLoading,
            onSend: () => viewModel.callAI(),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isUser;

  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
                : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9),
            borderRadius: isUser
                ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4))
                : const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16)),
          ),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isUser
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget tách riêng cho thanh input
class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.send,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: onSend,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
