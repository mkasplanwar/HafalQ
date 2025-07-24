import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1ABC9C);
  static const Color gold = Color(0xFFF7C873);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: gold,
    ),
    fontFamily: 'Poppins',
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: primaryGreen,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: Colors.black87,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      secondary: gold,
    ),
    fontFamily: 'Poppins',
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: gold,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
      ),
    ),
  );

  static const headerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryGreen,
  );
}
