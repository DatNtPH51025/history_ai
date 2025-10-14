import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthenticationNotifier() : super(null) {
    // Lắng nghe sự thay đổi trạng thái đăng nhập của Firebase
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  // Cung cấp thông tin người dùng hiện tại
  User? get currentUser => state;

  // Hàm đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

// Provider để truy cập trạng thái đăng nhập từ khắp nơi trong ứng dụng
final authProvider = StateNotifierProvider<AuthenticationNotifier, User?>((ref) {
  return AuthenticationNotifier();
});

