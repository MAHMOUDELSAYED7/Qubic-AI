import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MaterialApp(
        builder: (context, widget) {
          final mediaQueryData = MediaQuery.of(context);
          final scaledMediaQueryData = mediaQueryData.copyWith(
            textScaler: TextScaler.noScaling,
          );
          return MediaQuery(
            data: scaledMediaQueryData,
            child: widget!,
          );
        },
        debugShowCheckedModeBanner: false,
        title: 'Qubic AI',
        initialRoute: RouteManager.initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: AppTheme.darkTheme,
      ),
    );
  }
}
