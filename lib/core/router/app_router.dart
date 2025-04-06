import 'package:flutter/material.dart';
import 'package:qubic_ai/presentation/view/home.dart';
import 'routes.dart';
import '../../presentation/view/chat.dart';
import '../../presentation/view/splash.dart';
import 'page_transition.dart';

class AppRouter {
  const AppRouter._();
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteManager.initialRoute:
        return PageTransitionManager.fadeTransition(const SplashScreen());
      case RouteManager.home:
        return PageTransitionManager.fadeTransition(const HomeScreen());
      case RouteManager.chat:
        final sessionId = settings.arguments as List;
        final chatBloc = settings.arguments as List;
        return PageTransitionManager.slideTransition(ChatScreen(
          chatBloc: chatBloc[1],
          chatId: sessionId[0],
          isChatHistory: true,
        ));

      default:
        return null;
    }
  }
}
