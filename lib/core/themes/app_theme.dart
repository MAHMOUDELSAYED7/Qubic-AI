import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

class AppTheme {
  //!! dark THEME
  static ThemeData get darkTheme {
    return ThemeData(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: ColorManager.purple,
            foregroundColor: ColorManager.white),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(width: 2)),
            foregroundColor: ColorManager.white),
      ),
      iconTheme: const IconThemeData(color: ColorManager.white, size: 25),
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColorManager.black,
      //-----------------------------------------------------------//* APP BAR
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
          color: ColorManager.white,
          fontSize: 20.sp,
        ),
        backgroundColor: ColorManager.transparent,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: ColorManager.white),
        elevation: 0,
        shadowColor: ColorManager.dark.withOpacity(0.3),
      ),

      //-----------------------------------------------------------//* TEXT
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: 18.sp,
          color: ColorManager.white,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          fontSize: 15.sp,
          color: ColorManager.white,
          fontWeight: FontWeight.w300,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          color: ColorManager.white,
          fontWeight: FontWeight.w400,
        ),
      ),

      //-----------------------------------------------------------//* TEXT SELECTION
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: ColorManager.grey,
          selectionColor: ColorManager.grey.withOpacity(0.3),
          selectionHandleColor: ColorManager.grey),

      //--------------------------------------------------//* INPUT DECORATION Text Field
      inputDecorationTheme: InputDecorationTheme(
        // filled: false,
        // isDense: true,
        // fillColor: ColorManager.grey.withOpacity(0.12),
        contentPadding:
            EdgeInsets.only(left: 10, right: 10, top: 13.h, bottom: 13.h),
        hintStyle: const TextStyle(color: ColorManager.white),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
