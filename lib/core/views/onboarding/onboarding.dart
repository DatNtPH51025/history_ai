import 'package:flutter/material.dart';
import 'package:history_ai/core/views/auth/auth_wrapper.dart'; // ✅ Import AuthWrapper
import 'package:history_ai/core/views/auth/login_screen.dart';
// import 'package:history_ai/core/views/auth/login_screen.dart'; // Dùng AuthWrapper sẽ tốt hơn
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Import SharedPreferences

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ... (Phần UI không đổi) ...
            const Column(
              children: [
                Text(
                  'Your AI Assistant',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Using this software, you can ask you questions and receive articles using artificial intelligence assistant',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                )
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Image.asset('assets/onboarding.png'),
            const SizedBox(
              height: 32,
            ),
            ElevatedButton(
                onPressed: () async { // ✅ Chuyển thành async
                  // ✅ Lưu trạng thái đã xem onboarding
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasSeenOnboarding', true);

                  // ✅ Chuyển đến AuthWrapper thay vì LoginScreen
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Continue'),
                    SizedBox(
                      width: 8, // ✅ Nên dùng width cho Row
                    ),
                    Icon(Icons.arrow_forward)
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
