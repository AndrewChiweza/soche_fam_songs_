import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // MAIN COLORS — tuned to match your provided UI
  static const Color primaryGreen = Color(0xFF0B6B57);
  static const Color secondaryGreen = Color(0xff255F38);
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF18230F);
  static const Color darkCard = Color(0xFF27391C);

  // ---------------- LIGHT THEME ----------------
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: primaryGreen),
      titleTextStyle: GoogleFonts.ptSansCaption(
        color: primaryGreen,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.ptSansCaption(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
      ),
      bodyMedium: GoogleFonts.ptSansCaption(
        fontSize: 18,
        color: const Color(0xFF2F2F2F),
      ),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey.shade300,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: secondaryGreen,
      background: lightBackground,
    ),
  );

  // ---------------- DARK THEME ----------------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCard,
    appBarTheme: AppBarTheme(
      backgroundColor: darkCard,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.ptSansCaption(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.ptSansCaption(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.ptSansCaption(
        fontSize: 18,
        color: Colors.white.withOpacity(0.9),
      ),
    ),
    dividerColor: Colors.white10,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: secondaryGreen,
      background: darkBackground,
    ),
  );
}
