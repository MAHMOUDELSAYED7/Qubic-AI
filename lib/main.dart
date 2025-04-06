import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/di/locator.dart';
import 'core/service/local_notifications.dart';
import 'core/service/permission.dart';
import 'core/service/workmanger.dart';
import 'core/themes/colors.dart';
import 'data/source/database/hive_service.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails flutterErrorDetails) {
    FlutterError.dumpErrorToConsole(flutterErrorDetails);
  };

  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().initializeDatabase();
  await dotenv.load(fileName: '.env');
  setupServiceLocator();
  await PermissionService().requestNotificationPermission();
  await NotificationService().init();
  WorkManagerService.initialize();
  WorkManagerService.registerPeriodicNotificationTask();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: ColorManager.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}
