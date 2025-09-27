import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/models/message.dart';
import 'package:history_ai/core/theme/themeNotifier.dart';
import 'package:history_ai/view_models/home_view_model.dart';
import 'package:history_ai/widgets/message_bubble.dart';
import 'package:history_ai/widgets/message_input_bar.dart';


class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

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
                Text('HistoryAi', style: Theme.of(context).textTheme.titleLarge),
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
