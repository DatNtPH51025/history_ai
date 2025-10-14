import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/views/profile/profile_screen.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/view_models/home_view_model.dart';
import 'package:history_ai/widgets/message_bubble.dart';
import 'package:history_ai/widgets/message_input_bar.dart';

// ✅ BƯỚC 1: Thay đổi từ ConsumerWidget thành ConsumerStatefulWidget
class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  // ✅ BƯỚC 2: Tạo một ScrollController
  late final ScrollController _scrollController;
  void _showChatOptions(BuildContext context, ChatHistory chat) {
    showDialog(
      context: context,
      builder: (context) {
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
                  Navigator.pop(context); // Đóng hộp thoại tùy chọn
                  _showRenameDialog(context, chat);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title: Text('Xóa', style: TextStyle(color: Colors.red.shade700)),
                onTap: () {
                  Navigator.pop(context); // Đóng hộp thoại tùy chọn
                  _showDeleteConfirmationDialog(context, chat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ HÀM MỚI: Hiển thị hộp thoại đổi tên
  void _showRenameDialog(BuildContext context, ChatHistory chat) {
    final controller = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đổi tên cuộc trò chuyện'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Nhập tên mới"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).renameChat(chat.id, controller.text);
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // ✅ HÀM MỚI: Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmationDialog(BuildContext context, ChatHistory chat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa?'),
          content: Text('Bạn có chắc chắn muốn xóa cuộc trò chuyện "${chat.title}" không? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).deleteChat(chat.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Đừng quên dispose controller để tránh rò rỉ bộ nhớ
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    // ✅ BƯỚC 3: Lắng nghe sự thay đổi của danh sách tin nhắn để tự động cuộn
    ref.listen<int>(homeViewModelProvider.select((s) => s.messages.length),
            (previous, next) {
          // Đợi một chút để ListView build xong item mới rồi mới cuộn
          Future.delayed(const Duration(milliseconds: 50), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent, // Cuộn đến vị trí cuối cùng
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });

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
                itemCount: state.chatHistories.length,
                itemBuilder: (context, index) {
                  final chat = state.chatHistories[index];
                  return ListTile(
                    title: Text(
                      chat.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      viewModel.loadChat(chat.id);
                      Navigator.pop(context);
                    },
                    // ✅ THÊM SỰ KIỆN onLongPress
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
                viewModel.createNewChat('Cuộc trò chuyện mới');
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
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
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
              // ✅ BƯỚC 4: Gán controller cho ListView
              controller: _scrollController,
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
      ),
    );
  }
}

