import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'core/theme/themes.dart'; // lightMode and darkMode
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/chat_remote_datasource.dart';
import 'data/datasources/theme_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/theme_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/theme_repository.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/chat/chat_cubit.dart';
import 'presentation/cubits/theme/theme_cubit.dart';
import 'presentation/views/auth/auth_wrapper.dart';
import 'presentation/views/onboarding/onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final apiKey = dotenv.env['GOOGLE_API_KEY'];
  if (apiKey == null) {
    throw Exception("API_KEY không được tìm thấy trong file .env");
  }

  // Khởi tạo data sources
  final authRemoteDataSource = AuthRemoteDataSource();
  final chatRemoteDataSource = ChatRemoteDataSource(apiKey: apiKey);
  final themeLocalDataSource = ThemeLocalDataSource();

  // Khởi tạo repositories
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);
  final chatRepository = ChatRepositoryImpl(chatRemoteDataSource);
  final themeRepository = ThemeRepositoryImpl(themeLocalDataSource);

  // Lấy SharedPreferences để kiểm tra trạng thái Onboarding
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
        RepositoryProvider<ThemeRepository>.value(value: themeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(context.read<ThemeRepository>()),
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(
              chatRepository: context.read<ChatRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
        ],
        child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi của themeMode từ ThemeCubit
    final themeMode = context.watch<ThemeCubit>().state;

    return MaterialApp(
      title: 'History AI',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: hasSeenOnboarding ? const AuthWrapper() : const Onboarding(),
    );
  }
}
