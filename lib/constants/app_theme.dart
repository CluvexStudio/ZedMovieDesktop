import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color secondaryBlack = Color(0xFF141414);
  static const Color cardBlack = Color(0xFF1E1E1E);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8E8E8E);
  static const Color textDark = Color(0xFF2A2A2A);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentOrange = Color(0xFFF59E0B);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBlack,
      primaryColor: pureWhite,
      colorScheme: ColorScheme.dark(
        primary: accentPurple,
        secondary: accentBlue,
        surface: secondaryBlack,
        background: primaryBlack,
        error: accentPink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlack,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: pureWhite, size: 24),
        titleTextStyle: TextStyle(
          color: pureWhite,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBlack,
        elevation: 0,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPurple,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: pureWhite,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        displayMedium: TextStyle(
          color: pureWhite,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        bodyLarge: TextStyle(
          color: pureWhite,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      primaryColor: textDark,
      colorScheme: ColorScheme.light(
        primary: accentPurple,
        secondary: accentBlue,
        surface: cardWhite,
        background: offWhite,
        error: accentPink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark, size: 24),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPurple,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        displayMedium: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        bodyLarge: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      useMaterial3: true,
    );
  }

  static BoxShadow darkShadow({double blur = 20}) {
    return BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: blur,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    );
  }

  static BoxShadow lightShadow({double blur = 20}) {
    return BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: blur,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    );
  }

  static BoxDecoration cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? cardBlack : cardWhite,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [isDark ? darkShadow() : lightShadow()],
      border: isDark ? null : Border.all(
        color: Colors.grey.withValues(alpha: 0.1),
        width: 1,
      ),
    );
  }

  static BoxDecoration gradientOverlay(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark ? [
          Colors.transparent,
          primaryBlack.withValues(alpha: 0.7),
          primaryBlack,
        ] : [
          Colors.transparent,
          offWhite.withValues(alpha: 0.7),
          offWhite,
        ],
        stops: const [0.0, 0.65, 1.0],
      ),
    );
  }

  static LinearGradient get purpleGradient {
    return const LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get blueGradient {
    return const LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get pinkGradient {
    return const LinearGradient(
      colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

