import 'package:flutter/material.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<ThemeMode> getThemeMode() {
    return _localDataSource.getThemeMode();
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) {
    return _localDataSource.saveThemeMode(themeMode);
  }
}
