import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(
    typeId: 2)
class AppSettingsModel {
  @HiveField(0)
  final bool notificationsEnabled;
  
  @HiveField(1)
  final bool hasRequestedPermissionOnce;
  
  @HiveField(2)
  final DateTime? lastPermissionDeniedTime;

  AppSettingsModel({
    this.notificationsEnabled = true,
    this.hasRequestedPermissionOnce = false,
    this.lastPermissionDeniedTime,
  });

  AppSettingsModel copyWith({
    bool? notificationsEnabled,
    bool? hasRequestedPermissionOnce,
    DateTime? lastPermissionDeniedTime,
  }) {
    return AppSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hasRequestedPermissionOnce: hasRequestedPermissionOnce ?? this.hasRequestedPermissionOnce,
      lastPermissionDeniedTime: lastPermissionDeniedTime ?? this.lastPermissionDeniedTime,
    );
  }
}
