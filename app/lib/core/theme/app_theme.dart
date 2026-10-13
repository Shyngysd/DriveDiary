import 'package:flutter/material.dart';

class AppTheme {
  static const moneyFallback = <String>['Noto Sans'];
  static const receiptMoney = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: moneyFallback,
    fontSize: 12,
  );
  static const receiptMoneyLarge = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 40,
    fontWeight: FontWeight.w800,
  );
  static const moneySuffix = TextStyle(
    fontFamily: 'Noto Sans',
    fontSize: 12,
  );

  static const pageBackground = Color(0xFFEEF1F6);
  static const receiptPaper = Color(0xFFFFF8E1);
  static const ink = Color(0xFF1E293B);
  static const secondaryInk = Color(0xFF6B7280);
  static const receiptMutedInk = Color(0xFF526174);

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
