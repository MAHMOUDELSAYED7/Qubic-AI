import 'package:get_it/get_it.dart';

import '../../data/repositories/message_repository.dart';
import '../../data/source/apis/generative_ai_web_service.dart';
import '../../data/source/database/hive_service.dart';
import '../../presentation/bloc/chat/chat_bloc.dart';
import '../../presentation/bloc/input/input_field_bloc.dart';
import '../../presentation/bloc/launch_uri/launch_uri_cubit.dart';
import '../../presentation/bloc/search/search_bloc.dart';
import '../service/image_packer.dart';
import '../service/text_recognition.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<GenerativeAIWebService>(
      () => GenerativeAIWebService());
  sl.registerLazySingleton<HiveService>(() => HiveService());

  sl.registerLazySingleton<MessageRepository>(() => MessageRepository());

  sl.registerFactory<ChatBloc>(() => ChatBloc(
        sl<GenerativeAIWebService>(),
        sl<MessageRepository>(),
      ));
  sl.registerLazySingleton<SearchBloc>(() => SearchBloc(sl<ChatBloc>()));
  sl.registerLazySingleton<InputFieldBloc>(() => InputFieldBloc());
  sl.registerFactory<LaunchUriCubit>(() => LaunchUriCubit());

  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerService());
  sl.registerLazySingleton<TextRecognitionService>(
      () => TextRecognitionService());
}
