import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryRedDark = Color(0xFF8B181A);
  static const Color primaryRedLight = Color(0xFFA32123);
  
  static const Color cobaltBlue = Color(0xFF0047AB);
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color saffronYellow = Color(0xFFF4C430);
  
  static const Color backgroundWhite = Color(0xFFF5F5F7); // Apple standard background
  static const Color backgroundOffWhite = Color(0xFFFFFFFF); // Cards are white
  static const Color glassWhite = Color(0xCCFFFFFF); // For glass morphism
  static const Color textDark = Color(0xFF1D1D1F);
  static const Color textGrey = Color(0xFF86868B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRedDark, primaryRedLight],
    stops: [0.0, 1.0],
    transform: GradientRotation(2.35619), // 135 degrees in radians
  );

  static const LinearGradient zellijGradient = LinearGradient(
    colors: [Color(0xFF8B181A), Color(0xFF0047AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.outfit(
      fontSize: 32, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -1.0
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 28, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -0.5
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 24, fontWeight: FontWeight.w600, color: textDark
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 20, fontWeight: FontWeight.w600, color: textDark
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w600, color: textDark
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.normal, color: textDark
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.normal, color: textGrey
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white
    ),
  );

  // Main Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRedDark,
      scaffoldBackgroundColor: backgroundWhite,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRedDark,
        primary: primaryRedDark,
        secondary: cobaltBlue,
        tertiary: saffronYellow,
        background: backgroundWhite,
        surface: backgroundOffWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRedDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryRedDark.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundOffWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryRedDark, width: 2),
        ),
        prefixIconColor: textGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textDark, fontSize: 20, fontWeight: FontWeight.bold
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
    );
  }
}
