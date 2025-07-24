import 'package:flutter/material.dart';

class ThemeFontProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  int _fontSize = 16;

  ThemeMode get themeMode => _themeMode;
  int get fontSize => _fontSize;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontSize(int size) {
    _fontSize = size;
    notifyListeners();
  }
}
