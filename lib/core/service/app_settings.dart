import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/app_settings_model.dart';

class AppSettingsService {
  static const String _boxName = 'app_settings';
  static const String _settingsKey = 'settings';

  static AppSettingsService? _instance;

  static AppSettingsService get instance =>
      _instance ??= AppSettingsService._();

  AppSettingsService._();

  Box<AppSettingsModel>? _box;

  Future<void> init() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<AppSettingsModel>(_boxName);
      }
    } catch (e) {
      debugPrint('Error opening app settings box: $e');
      rethrow;
    }
  }

  Future<bool> getNotificationsEnabled() async {
    try {
      await init();
      final settings = _box?.get(_settingsKey);
      if (settings == null) {
        await setNotificationsEnabled(true);
        return true;
      }
      return settings.notificationsEnabled;
    } catch (e) {
      debugPrint('Error getting notifications enabled: $e');
      return true; 
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await init();
      final currentSettings = _box?.get(_settingsKey) ?? AppSettingsModel();
      final updatedSettings = currentSettings.copyWith(
        notificationsEnabled: enabled,
      );
      await _box?.put(_settingsKey, updatedSettings);
    } catch (e) {
      debugPrint('Error setting notifications enabled: $e');
      rethrow;
    }
  }

  Future<bool> hasRequestedPermissionOnce() async {
    try {
      await init();
      final settings = _box?.get(_settingsKey);
      return settings?.hasRequestedPermissionOnce ?? false;
    } catch (e) {
      debugPrint('Error getting permission request status: $e');
      return false;
    }
  }

  Future<void> setPermissionRequested() async {
    try {
      await init();
      final currentSettings = _box?.get(_settingsKey) ?? AppSettingsModel();
      final updatedSettings = currentSettings.copyWith(
        hasRequestedPermissionOnce: true,
      );
      await _box?.put(_settingsKey, updatedSettings);
    } catch (e) {
      debugPrint('Error setting permission requested: $e');
      rethrow;
    }
  }

  Future<void> setPermissionDeniedTime() async {
    try {
      await init();
      final currentSettings = _box?.get(_settingsKey) ?? AppSettingsModel();
      final updatedSettings = currentSettings.copyWith(
        lastPermissionDeniedTime: DateTime.now(),
      );
      await _box?.put(_settingsKey, updatedSettings);
    } catch (e) {
      debugPrint('Error setting permission denied time: $e');
      rethrow;
    }
  }

  Future<bool> wasPermissionRecentlyDenied() async {
    try {
      await init();
      final settings = _box?.get(_settingsKey);
      final lastDeniedTime = settings?.lastPermissionDeniedTime;
      
      if (lastDeniedTime == null) return false;
      
      // إذا تم رفض الـ permission في آخر 10 ثواني، لا نطلبه مرة أخرى
      final timeDifference = DateTime.now().difference(lastDeniedTime);
      return timeDifference.inSeconds < 10;
    } catch (e) {
      debugPrint('Error checking recent permission denial: $e');
      return false;
    }
  }
}
