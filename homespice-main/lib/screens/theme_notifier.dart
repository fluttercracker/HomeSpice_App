import 'package:flutter/material.dart';
import 'package:homespice/screens/app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.Light:
        _themeMode = ThemeMode.light;
        break;
      case AppTheme.Dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppTheme.System:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
}
