import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider để cung cấp ThemeNotifier cho ứng dụng
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});


class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Key để lưu theme mode vào SharedPreferences
  final String key = "theme";
  late SharedPreferences _prefs;

  // Constructor: mặc định là ThemeMode.system
  ThemeNotifier() : super(ThemeMode.system) {
    _loadFromPrefs();
  }

  // Tải theme đã lưu từ SharedPreferences
  _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs.getInt(key) ?? ThemeMode.system.index;
    state = ThemeMode.values[themeIndex];
  }

  // Lưu theme vào SharedPreferences
  _saveToPrefs(ThemeMode themeMode) {
    _prefs.setInt(key, themeMode.index);
  }

  // Hàm để chuyển đổi theme
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
    _saveToPrefs(state);
  }
}
