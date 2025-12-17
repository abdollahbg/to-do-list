// notification_settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  static const String _notificationsEnabledKey = 'notifications_enabled';

  /// إرجاع حالة الإشعارات (مفعّلة أو لا)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// تعيين حالة الإشعارات
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }
}
