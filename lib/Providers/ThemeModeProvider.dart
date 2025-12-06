import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider extends ChangeNotifier {
  bool isDark;
  late SharedPreferences _prefs;

  ThemeModeProvider(this.isDark) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void changeThemeMode(bool value) {
    isDark = value;
    _prefs.setBool('isDark', value);
    notifyListeners();
  }
}
