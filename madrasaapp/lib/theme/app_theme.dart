import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF401B7E);

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      fontFamily: 'NotoSans',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 24,
          height: 1.5,
        ),
        titleLarge: TextStyle(
          fontFamily: 'NotoSans',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
