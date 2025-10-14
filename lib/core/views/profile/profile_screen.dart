import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:history_ai/core/views/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: user == null
          ? const Center(
        child: Text('Không có thông tin người dùng'),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ảnh đại diện
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : const AssetImage('assets/user_avatar.png')
              as ImageProvider,
            ),
            const SizedBox(height: 20),

            // Tên người dùng
            Text(
              user.displayName ?? 'Người dùng chưa đặt tên',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Email
            Text(
              user.email ?? 'Không có email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 40),

            // Nút đăng xuất
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đăng xuất thành công!'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
