// notification_provider.dart
import 'package:flutter/material.dart';
import 'package:to_do_list/services/notification_service.dart';
import 'package:to_do_list/services/notification_settings_service.dart';

class NotificationProvider with ChangeNotifier {
  bool _enabled = true;

  bool get enabled => _enabled;

  NotificationProvider() {
    _loadStatus();
  }

  /// تحميل حالة الإشعارات عند تشغيل التطبيق
  Future<void> _loadStatus() async {
    _enabled = await NotificationSettingsService.isEnabled();
    notifyListeners();
  }

  /// لتفعيل أو تعطيل الإشعارات
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await NotificationSettingsService.setEnabled(value);

    if (!value) {
      // إذا تم تعطيل الإشعارات، نلغي جميع الإشعارات المجدولة
      await NotificationService.cancelAllNotifications();
    }

    notifyListeners();
  }
}
