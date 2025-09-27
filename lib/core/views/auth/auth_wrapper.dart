import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/view_models/auth_view_model.dart';
import '../home/home_page.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.user != null) {
      return const MyHomePage(); // ✅ Nếu đã login
    } else {
      return LoginScreen(); // ❌ Nếu chưa login
    }
  }
}
