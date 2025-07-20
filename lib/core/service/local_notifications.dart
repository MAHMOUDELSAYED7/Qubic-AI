import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app_settings.dart';
import 'permission.dart';

class NotificationService {
  static NotificationService? _instance;

  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _permissionService = PermissionService();
  final _appSettings = AppSettingsService.instance;

  static const String channelId = 'qubic_ai_channel';
  static const String channelName = 'Qubic AI Reminders';
  static const String channelDescription =
      'Notifications for Qubic AI reminders';
  bool _isInitialized = false;

  Future<void> init({bool createChannel = true}) async {
    if (_isInitialized) {
      return;
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (createChannel) {
        await _createNotificationChannel();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        showBadge: true,
        enableVibration: true,
        playSound: true,
        enableLights: true,
      );

      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);

        await androidImplementation.requestExactAlarmsPermission();

        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        await init(createChannel: true);
      }

      final notificationsEnabled = await _appSettings.getNotificationsEnabled();
      if (!notificationsEnabled) {
        return;
      }

      final hasPermission =
          await _permissionService.checkNotificationPermission();
      if (!hasPermission) {
        final granted =
            await _permissionService.requestNotificationPermission();
        if (!granted) {
          return;
        }
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        autoCancel: true,
        ongoing: false,
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error in showNotification: $e');
      rethrow;
    }
  }
}
