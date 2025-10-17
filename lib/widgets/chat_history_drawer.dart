import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/view_models/home_view_model.dart';

class ChatHistoryDrawer extends ConsumerWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử trò chuyện',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Tạo cuộc trò chuyện mới',
                  onPressed: () {
                    viewModel.createNewChat('Cuộc trò chuyện mới');
                    Navigator.pop(context); // Đóng drawer
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.chatHistories.length,
              itemBuilder: (context, index) {
                final chat = state.chatHistories[index];
                // Sử dụng một widget con để tối ưu và làm code sạch hơn
                return _ChatHistoryTile(
                  chat: chat,
                  isActive: chat.id == state.activeChatId,
                  onTap: () {
                    viewModel.loadChat(chat.id);
                    Navigator.pop(context); // Đóng drawer
                  },
                  onLongPress: () => _showChatOptions(context, ref, chat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM DIALOG ĐƯỢC CHUYỂN VÀO ĐÂY ---

  void _showChatOptions(BuildContext context, WidgetRef ref, ChatHistory chat) {
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
                  _showRenameDialog(context, ref, chat);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title: Text('Xóa', style: TextStyle(color: Colors.red.shade700)),
                onTap: () {
                  Navigator.pop(context); // Đóng hộp thoại tùy chọn
                  _showDeleteConfirmationDialog(context, ref, chat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, ChatHistory chat) {
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
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

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, ChatHistory chat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa?'),
          content: Text('Bạn có chắc chắn muốn xóa cuộc trò chuyện "${chat.title}" không? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
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
}


// Widget con cho từng item trong drawer, giúp UI đẹp và dễ quản lý hơn
class _ChatHistoryTile extends StatelessWidget {
  final ChatHistory chat;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ChatHistoryTile({
    required this.chat,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          chat.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Theme.of(context).colorScheme.primary : null
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
