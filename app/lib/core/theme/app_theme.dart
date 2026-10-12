import 'package:flutter/material.dart';

class AppTheme {
  static const pageBackground = Color(0xFFEEF1F6);
  static const receiptPaper = Color(0xFFFFF8E1);
  static const ink = Color(0xFF1E293B);
  static const secondaryInk = Color(0xFF6B7280);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: pageBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF526A8D),
      brightness: Brightness.light,
    ),
    fontFamily: 'Manrope',
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF111827),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8EA7CC),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Manrope',
  );
}
