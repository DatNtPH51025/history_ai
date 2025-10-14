import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/views/profile/profile_screen.dart';
import 'package:history_ai/view_models/home_view_model.dart';
import 'package:history_ai/widgets/message_bubble.dart';
import 'package:history_ai/widgets/message_input_bar.dart';


class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Text(
                'Lịch sử chat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.chatHistories.length, // danh sách chat
                itemBuilder: (context, index) {
                  final chat = state.chatHistories[index];
                  return ListTile(
                    title: Text(chat.title), // tên chat
                    subtitle: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      viewModel.loadChat(chat.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        automaticallyImplyLeading: true, // để Flutter thêm menu icon tự động
        title: Text(
          'History AI',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/splashscreen.png'),
              ),
            ),
          ),
        ],
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
