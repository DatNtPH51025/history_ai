import 'package:flutter/material.dart';

class FontSizes {
  static const extraSmall = 14.0;
  static const small = 16.0;
  static const standard = 18.0;
  static const large = 20.0;
  static const extraLarge = 24.0;
  static const doubleExtraLarge = 26.0;
}

/// ☀️ Giao diện sáng
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    shadowColor: Colors.grey,
  ),
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xff3369FF),
    secondary: Color(0xffEEEEEE),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.blue),
    border: OutlineInputBorder(),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: Colors.black,
      fontSize: FontSizes.large,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Colors.black87,
      fontSize: FontSizes.standard,
    ),
    bodyMedium: TextStyle(
      color: Colors.black87,
      fontSize: FontSizes.small,
    ),
    bodySmall: TextStyle(
      color: Colors.black54,
      fontSize: FontSizes.extraSmall,
    ),
  ),
);

/// 🌙 Giao diện tối (tối ưu cho chat AI)
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    shadowColor: Color(0xff333333),
  ),
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF121212),
    primary: Color(0xFF3369FF), // user bubble
    secondary: Color(0xFF2C2C2C),
    secondaryContainer: Color(0xFF2A2D3A), // AI bubble màu nền
    onSurface: Colors.white70, // văn bản AI
    onPrimary: Colors.white,   // văn bản user
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.lightBlueAccent),
    border: OutlineInputBorder(),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: FontSizes.large,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Colors.white70,
      fontSize: FontSizes.standard,
    ),
    bodyMedium: TextStyle(
      color: Colors.white70,
      fontSize: FontSizes.small,
    ),
    bodySmall: TextStyle(
      color: Colors.white60,
      fontSize: FontSizes.extraSmall,
    ),
  ),
);
