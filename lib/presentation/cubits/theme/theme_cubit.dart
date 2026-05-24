import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/theme_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeRepository _themeRepository;

  ThemeCubit(this._themeRepository) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _themeRepository.getThemeMode();
    emit(mode);
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _themeRepository.saveThemeMode(nextMode);
    emit(nextMode);
  }
}
