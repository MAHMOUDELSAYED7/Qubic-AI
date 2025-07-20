import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'app_settings.dart';
import 'local_notifications.dart';
import 'notification_manager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationService = NotificationService.instance;
    final appSettings = AppSettingsService.instance;

    try {
      final notificationsEnabled = await appSettings.getNotificationsEnabled();
      if (!notificationsEnabled) {
        return Future.value(true);
      }

      await notificationService.init(createChannel: true);

      await notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, //! Unique ID
        title: 'Qubic AI Reminder',
        body: "You can ask Qubic AI about anything! Tap to open.",
        payload: 'background_reminder',
      );
    } catch (err) {
      debugPrint("Error in background task: $err");
    }
    return Future.value(true);
  });
}

class WorkManagerService {
  static const String periodicTaskName = "periodicNotificationTask";
  static const String taskUniqueId = "1";

  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    _initializeWithNotificationCheck();
  }

  static Future<void> _initializeWithNotificationCheck() async {
    try {
      await NotificationManager.instance.initializeNotificationSettings();
      
      final appSettings = AppSettingsService.instance;
      final notificationsEnabled = await appSettings.getNotificationsEnabled();
      
      if (notificationsEnabled) {
        _registerPeriodicNotificationTask();
        debugPrint('📅 Periodic notifications registered');
      } else {
        cancelPeriodicNotificationTask();
        debugPrint('🚫 Notifications disabled - no background task');
      }
    } catch (e) {
      debugPrint('Error initializing WorkManager: $e');
    }
  }

  static void _registerPeriodicNotificationTask() {
    Workmanager().cancelByUniqueName(taskUniqueId);

    Workmanager().registerPeriodicTask(
      taskUniqueId,
      periodicTaskName,
      frequency: const Duration(minutes: 15),
      initialDelay: Duration.zero,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static void cancelPeriodicNotificationTask() {
    Workmanager().cancelByUniqueName(taskUniqueId);
  }

  static void enableNotifications() {
    _registerPeriodicNotificationTask();
  }

  static void disableNotifications() {
    cancelPeriodicNotificationTask();
  }
}
