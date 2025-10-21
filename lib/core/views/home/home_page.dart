import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/views/profile/profile_screen.dart';
import 'package:history_ai/providers/auth_provider.dart'; // Import để lấy thông tin user
import 'package:history_ai/providers/connectivity_provider.dart';
import 'package:history_ai/widgets/chat_history_drawer.dart';
import 'package:history_ai/widgets/chat_view.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy thông tin người dùng để hiển thị avatar
    final user = ref.watch(authProvider);
    final isConnected = ref.watch(isConnectedProvider); //

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Widget Drawer đã được tách ra
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        // Builder để lấy context mới cho Scaffold.of(context).openDrawer()
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Lịch sử trò chuyện',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('History AI', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              // Hiển thị avatar của người dùng
              child: CircleAvatar(
                radius: 18,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null ? const Icon(Icons.person, size: 18) : null,
              ),
            ),
          ),
        ],
        bottom: isConnected
            ? null // Không hiển thị gì khi có mạng
            : PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: Container(
            height: 24,
            width: double.infinity,
            color: Colors.orange.shade800,
            child: const Center(
              child: Text(
                'Không có kết nối mạng',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
      // Toàn bộ phần thân của trang đã được tách ra
      body: const ChatView(),
    );
  }
}
