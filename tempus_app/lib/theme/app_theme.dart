import 'package:flutter/material.dart';

/// Design tokens do Tempus.
///
/// Superfícies levemente tingidas de violeta (em vez de cinza neutro) para
/// harmonizar com o acento, e textos secundários com contraste ≥ 4.5:1
/// sobre o fundo.
class TempusColors {
  static const Color bg = Color(0xFF05040A);
  static const Color surface = Color(0xFF0F0D16);
  static const Color surfaceHigh = Color(0xFF17141F);
  static const Color surfaceHigher = Color(0xFF201C2B);
  static const Color border = Color(0xFF26222F);
  static const Color borderFaint = Color(0x14FFFFFF);

  static const Color text = Color(0xFFF5F3FA);
  static const Color textSub = Color(0xFF9592A6);
  static const Color textMuted = Color(0xFF5C596B);

  static const Color accent = Color(0xFFA855F7);
  static const Color accentSoft = Color(0xFFC4A1FF);
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

  /// Gradiente de cartão "hero" — profundidade sutil sem competir com o conteúdo.
  static const LinearGradient heroCard = LinearGradient(
    colors: [Color(0xFF1A1428), Color(0xFF0D0B16)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class TempusRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
}

class AppTheme {
  static const String fontFamily = 'Manrope';

  static ThemeData get darkTheme {
    final base = ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      useMaterial3: true,
    );
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: TempusColors.accent,
        secondary: TempusColors.accentBlue,
        surface: TempusColors.surface,
        error: TempusColors.red,
      ),
      splashFactory: InkSparkle.splashFactory,
      cardTheme: CardThemeData(
        color: TempusColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TempusRadius.md),
          side: const BorderSide(color: TempusColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TempusColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TempusRadius.lg),
          side: const BorderSide(color: TempusColors.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TempusColors.surfaceHigher,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: TempusColors.text,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TempusRadius.md),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: TempusColors.accent,
        inactiveTrackColor: TempusColors.border,
        thumbColor: Colors.white,
        overlayColor: Color(0x22A855F7),
        trackHeight: 4,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: TempusColors.text,
        displayColor: TempusColors.text,
      ),
    );
  }
}
