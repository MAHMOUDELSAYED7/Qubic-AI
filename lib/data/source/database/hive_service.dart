import 'package:hive_flutter/hive_flutter.dart';

import '../../models/app_settings_model.dart';
import '../../models/hive.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  Future<void> initializeDatabase() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ChatSessionAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());

    await Hive.openBox<Message>('messages');
    await Hive.openBox<ChatSession>('chat_sessions');
    await Hive.openBox<AppSettingsModel>('app_settings');
  }

  Future<void> deleteAndRecreateDatabase() async {
    await Hive.close();
    await Hive.deleteBoxFromDisk('messages');
    await Hive.deleteBoxFromDisk('chat_sessions');
    await Hive.deleteBoxFromDisk('app_settings');

    await initializeDatabase();
  }
}
