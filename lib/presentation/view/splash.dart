import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/themes/colors.dart';
import 'package:qubic_ai/core/router/routes.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';

import '../../core/utils/constants/images.dart';
import '../../core/widgets/colorize_text_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async => Future.delayed(
      const Duration(seconds: 3),
      () => Navigator.pushReplacementNamed(context, RouteManager.home));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Stack(
        alignment: Alignment.center,
        children: [
          ZoomIn(
            duration: const Duration(milliseconds: 2000),
            child: Bounce(
              child: Image.asset(
                ImageManager.logo,
                width: 100.w,
                height: 100.w,
              ),
            ),
          ),
          Positioned(
            bottom: 50.h,
            child: ColorizeAnimatedText(
              "Qubic AI",
              speed: const Duration(milliseconds: 500),
              textStyle: context.textTheme.bodyLarge!.copyWith(
                fontSize: 30.0.sp,
              ),
              colors: ColorManager.colorizeColors,
            ),
          ),
        ],
      ).withSize(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
