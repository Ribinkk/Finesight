import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF10B981); // Emerald default

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString('themeMode');
    final colorInt = prefs.getInt('primaryColor');

    if (modeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () => ThemeMode.system,
      );
    }

    if (colorInt != null) {
      _primaryColor = Color(colorInt);
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString());
    await prefs.setInt('primaryColor', _primaryColor.toARGB32());
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _saveToPrefs();
    notifyListeners();
  }

  void resetToDefaults() {
    _themeMode = ThemeMode.system;
    _primaryColor = const Color(0xFF10B981);
    _saveToPrefs();
    notifyListeners();
  }
}
