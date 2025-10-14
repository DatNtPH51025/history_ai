import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:history_ai/core/views/auth/auth_wrapper.dart';
import 'package:history_ai/core/views/onboarding/onboarding.dart'; // ✅ Import Onboarding
import 'package:history_ai/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Import SharedPreferences
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Lấy SharedPreferences để kiểm tra
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(ProviderScope(
    child: MyApp(hasSeenOnboarding: hasSeenOnboarding), // ✅ Truyền giá trị vào MyApp
  ));
}

class MyApp extends ConsumerWidget {
  final bool hasSeenOnboarding; // ✅ Nhận giá trị

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'History AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      // ✅ Quyết định màn hình đầu tiên ở đây
      home: hasSeenOnboarding ? const AuthWrapper() : const Onboarding(),
    );
  }
}

