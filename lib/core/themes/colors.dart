import 'package:flutter/material.dart';

class ColorManager {
  const ColorManager._();

  static Color dark = Colors.grey.shade900;
  static Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color purple = Colors.purple;
  static Color? error = Colors.red[700];

  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  // Code block colors
  static Color? codeBlockBg = Colors.black.withValues(alpha: 0.3);
  static const Color codeHeaderBg = Color(0xFF3A3A3A);
  static const Color codeHeaderText = Color(0xFF858585);
  static const Color codeHeaderIcon = Color(0xFFB3B3B3);
  static const Color codeBaseText = Color(0xFFE0E0E0);

  // Syntax highlighting colors
  static const Color codeComment = Color(0xFF6A9955);
  static const Color codeString = Color(0xFFCE9178);
  static const Color codeKeyword = Color(0xFF569CD6);
  static const Color codeType = Color(0xFF4EC9B0);
  static const Color codeNumber = Color(0xFFB5CEA8);
  static const Color codeSymbol = Color(0xFFD7BA7D);
  static const Color codeClass = Color(0xFF4EC9B0);
  static const Color codeFunction = Color(0xFFDCDCAA);
  static const Color codeVariable = Color(0xFF9CDCFE);

  // Inline code colors
  static const Color inlineCodeBg = Color(0x15FFFFFF);
  static const Color inlineCodeText = Color(0xFFD4D4D4);
}
