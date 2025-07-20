import 'app_settings.dart';
import 'permission.dart';

class NotificationManager {
  static NotificationManager? _instance;
  static NotificationManager get instance =>
      _instance ??= NotificationManager._();
  NotificationManager._();

  bool _hasRequestedInThisSession = false;

  Future<void> initializeNotificationSettings() async {
    final appSettings = AppSettingsService.instance;
    final hasRequestedBefore = await appSettings.hasRequestedPermissionOnce();

    if (!hasRequestedBefore && !_hasRequestedInThisSession) {
      _hasRequestedInThisSession = true;
      await appSettings.setPermissionRequested();
      
      final hasPermission = await PermissionService().requestNotificationPermission();
      await appSettings.setNotificationsEnabled(hasPermission);
    }
  }

  Future<bool> requestPermissionFromSettings() async {
    final permissionService = PermissionService();
    final appSettings = AppSettingsService.instance;
    
    final hasPermission = await permissionService.checkNotificationPermission();
    if (hasPermission) return true;
    
    final hasRequestedBefore = await appSettings.hasRequestedPermissionOnce();
    if (!hasRequestedBefore && !_hasRequestedInThisSession) {
      _hasRequestedInThisSession = true;
      await appSettings.setPermissionRequested();
      return await permissionService.requestNotificationPermission();
    }
    
    return false;
  }

  Future<bool> isPermissionPermanentlyDenied() async {
    return await PermissionService().isPermissionPermanentlyDenied();
  }

  Future<void> openSystemSettings() async {
    await PermissionService().openSystemAppSettings();
  }

  Future<bool> getNotificationStatus() async {
    return await AppSettingsService.instance.getNotificationsEnabled();
  }
}
