import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Oriva design tokens — Luxe africain, noir profond + or
class OrivaColors {
  // Fond
  static const Color black = Color(0xFF080808);
  static const Color surface = Color(0xFF111111);
  static const Color card = Color(0xFF161616);
  static const Color border = Color(0xFF222222);

  // Accent
  static const Color gold = Color(0xFFC9A96E);
  static const Color goldLight = Color(0xFFD9BB8E);
  static const Color goldDark = Color(0xFFB08F52);

  // Texte
  static const Color cream = Color(0xFFF5F0E8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B6B6B);

  // États
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFE53935);
}

class OrivaTypography {
  static TextStyle display({double size = 40, FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        color: color ?? OrivaColors.cream,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle body({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? OrivaColors.cream,
        height: 1.5,
      );

  static TextStyle label({double size = 12, Color? color}) => GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? OrivaColors.muted,
        letterSpacing: 1.5,
      );
}

class OrivaTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: OrivaColors.black,
      colorScheme: const ColorScheme.dark(
        primary: OrivaColors.gold,
        onPrimary: OrivaColors.black,
        secondary: OrivaColors.goldLight,
        surface: OrivaColors.surface,
        onSurface: OrivaColors.cream,
        error: OrivaColors.danger,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: OrivaColors.cream,
        displayColor: OrivaColors.cream,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: OrivaColors.black,
        elevation: 0,
        titleTextStyle: OrivaTypography.display(size: 22, weight: FontWeight.w500),
        iconTheme: const IconThemeData(color: OrivaColors.cream),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OrivaColors.gold,
          foregroundColor: OrivaColors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OrivaColors.cream,
          side: const BorderSide(color: OrivaColors.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OrivaColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrivaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrivaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OrivaColors.gold, width: 1.5),
        ),
        labelStyle: OrivaTypography.label(),
        hintStyle: OrivaTypography.body(color: OrivaColors.muted),
      ),
      cardTheme: CardTheme(
        color: OrivaColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: OrivaColors.border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: OrivaColors.black,
        selectedItemColor: OrivaColors.gold,
        unselectedItemColor: OrivaColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
