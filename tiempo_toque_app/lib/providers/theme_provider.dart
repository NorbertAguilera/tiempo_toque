import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  static const String _boxName = 'theme_preferences';
  static const String _keyDarkMode = 'isDarkMode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    var box = await Hive.openBox(_boxName);
    _isDarkMode = box.get(_keyDarkMode, defaultValue: false) as bool;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    var box = await Hive.openBox(_boxName);
    await box.put(_keyDarkMode, _isDarkMode);
    notifyListeners();
  }
}
