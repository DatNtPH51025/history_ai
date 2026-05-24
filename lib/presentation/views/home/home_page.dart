import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chat_history.dart';
import '../../cubits/chat/chat_cubit.dart';
import '../../cubits/chat/chat_state.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input_bar.dart';
import '../profile/profile_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ScrollController _scrollController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showChatOptions(BuildContext context, ChatHistory chat) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            'Tùy chọn cho "${chat.title}"',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Đổi tên'),
                onTap: () {
                  Navigator.pop(dialogCtx); // Đóng hộp thoại tùy chọn
                  _showRenameDialog(context, chat);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title: Text('Xóa', style: TextStyle(color: Colors.red.shade700)),
                onTap: () {
                  Navigator.pop(dialogCtx); // Đóng hộp thoại tùy chọn
                  _showDeleteConfirmationDialog(context, chat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, ChatHistory chat) {
    final controller = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Đổi tên cuộc trò chuyện'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Nhập tên mới"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                context.read<ChatCubit>().renameChat(chat.id, controller.text);
                Navigator.pop(dialogCtx);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ChatHistory chat) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa?'),
          content: Text(
              'Bạn có chắc chắn muốn xóa cuộc trò chuyện "${chat.title}" không? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                context.read<ChatCubit>().deleteChat(chat.id);
                Navigator.pop(dialogCtx);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _scrollDown() {
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

  @override
  Widget build(BuildContext context) {
    final chatState = context.watch<ChatCubit>().state;

    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (prev, current) => prev.messages.length != current.messages.length,
      listener: (context, state) {
        _scrollDown();
      },
      child: Scaffold(
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
                  itemCount: chatState.chatHistories.length,
                  itemBuilder: (context, index) {
                    final chat = chatState.chatHistories[index];
                    return ListTile(
                      title: Text(
                        chat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        context.read<ChatCubit>().loadChat(chat.id);
                        Navigator.pop(context);
                      },
                      onLongPress: () {
                        _showChatOptions(context, chat);
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Tạo cuộc trò chuyện mới'),
                onTap: () {
                  context.read<ChatCubit>().createNewChat('Cuộc trò chuyện mới');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 1,
          automaticallyImplyLeading: true,
          title: Text('History AI', style: Theme.of(context).textTheme.titleLarge),
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
                controller: _scrollController,
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final message = chatState.messages[index];
                  return MessageBubble(
                    message: message,
                    isUser: message.isUser,
                  );
                },
              ),
            ),
            MessageInputBar(
              controller: _messageController,
              isLoading: chatState.isLoading,
              onSend: () {
                final text = _messageController.text.trim();
                if (text.isNotEmpty) {
                  _messageController.clear();
                  context.read<ChatCubit>().sendChatMessage(text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
