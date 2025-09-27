import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/view_models/auth_view_model.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authVM = ref.read(authProvider.notifier);

    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
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
                      authVM.signUp(
                          emailCtrl.text.trim(), passCtrl.text.trim());
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ),
    );
  }
}
