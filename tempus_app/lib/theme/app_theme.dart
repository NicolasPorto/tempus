import 'package:flutter/material.dart';

class TempusColors {
  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surfaceHigh = Color(0xFF141414);
  static const Color border = Color(0xFF252525);
  static const Color borderFaint = Color(0x0CFFFFFF);

  static const Color text = Color(0xFFFFFFFF);
  static const Color textSub = Color(0xFF686868);
  static const Color textMuted = Color(0xFF3A3A3A);

  static const Color accent = Color(0xFFA855F7);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color green = Color(0xFF34D399);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFFF4D5E);

  static const LinearGradient gradient = LinearGradient(
    colors: [accent, accentBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientDiag = LinearGradient(
    colors: [accent, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: TempusColors.accent,
          secondary: TempusColors.accentBlue,
          surface: TempusColors.surface,
        ),
        cardTheme: CardThemeData(
          color: TempusColors.surface,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: TempusColors.border),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: TempusColors.textSub,
            fontFamily: 'Arimo',
          ),
          bodyLarge: TextStyle(
            color: TempusColors.text,
            fontFamily: 'Arimo',
          ),
          titleLarge: TextStyle(
            color: TempusColors.text,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
