import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/views/home/home_page.dart';
// Giả sử bạn có màn hình login
import 'package:history_ai/core/views/auth/login_screen.dart';
import 'package:history_ai/providers/auth_provider.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng "when" để xử lý các trạng thái rõ ràng hơn
    final authState = ref.watch(authStateProvider); // Giả sử bạn có một provider trả về AsyncValue

    return authState.when(
      data: (user) {
        if (user != null) {
          // Nếu đã đăng nhập, vào màn hình chính
          return const MyHomePage();
        } else {
          // Nếu chưa đăng nhập, vào màn hình đăng nhập
          return const LoginScreen(); // Hoặc placeholder của bạn
        }
      },
      // Khi đang tải (ví dụ: khi ứng dụng khởi động hoặc đang đăng xuất)
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      // Nếu có lỗi
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Đã xảy ra lỗi: $err'),
        ),
      ),
    );
  }
}

// Bạn nên tạo một provider mới như thế này trong auth_provider.dart
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

