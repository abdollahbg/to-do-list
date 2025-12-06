import 'package:shared_preferences/shared_preferences.dart';

class Preferenceservice {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setThemeMode(bool isDark) async {
    return await _prefs.setBool('is_dark_mode', isDark);
  }

  bool getThemeMode() {
    return _prefs.getBool('is_dark_mode') ?? false;
  }

  Future<bool> removeKey(String key) async {
    return await _prefs.remove(key);
  }
}
