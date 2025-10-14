import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ✅ SỬA 1: Đổi import về đúng file provider đã tạo ở bước trước
import 'package:history_ai/providers/auth_provider.dart';
import 'package:history_ai/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeNotifierProvider);
    // Lấy thông tin người dùng từ authProvider
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Cài đặt'),
      ),
      body: ListView(
        children: [
          // ✅ SỬA 2: Kiểm tra xem user có null không trước khi hiển thị header
          if (user != null)
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName ?? 'Không có tên'),
              accountEmail: Text(user.email ?? 'Không có email'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: (user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                // Thêm 'as ImageProvider' để ép kiểu rõ ràng
                    : const AssetImage('assets/splashscreen.png'))
                as ImageProvider,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            )
          else
          // Hiển thị một placeholder nếu không có thông tin người dùng
            const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          ListTile(
            title: const Text('Chế độ tối'),
            trailing: IconButton(
              icon: Icon(
                currentThemeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text('Đăng xuất', style: TextStyle(color: Colors.red.shade700)),
            onTap: () async {
              // Gọi hàm signOut từ provider
              await ref.read(authProvider.notifier).signOut();
              // Đóng tất cả các màn hình và quay về AuthWrapper
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          )
        ],
      ),
    );
  }
}
