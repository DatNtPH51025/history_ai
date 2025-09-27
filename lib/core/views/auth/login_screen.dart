import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/views/auth/signup_screen.dart';
import 'package:history_ai/core/views/home/home_page.dart';
import 'package:history_ai/view_models/auth_view_model.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authVM = ref.read(authProvider.notifier);

    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    // 👇 Lắng nghe thay đổi AuthState
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.user != null && prev?.user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });


    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            if (authState.error != null)
              Text(
                authState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authVM.signIn(
                    emailCtrl.text.trim(), passCtrl.text.trim());
              },
              child: const Text("Login"),
            ),
            ElevatedButton(
              onPressed: () {
                authVM.signInWithGoogle();
              },
              child: const Text("Login with Google"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}
