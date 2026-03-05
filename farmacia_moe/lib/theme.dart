import 'package:flutter/material.dart';

class MoeTheme {
  static const Color primaryBlue = Color(0xFF0D47A1); // Azul profundo
  static const Color accentBlue = Color(0xFF1976D2);  // Azul vibrante
  static const Color lightBlue = Color(0xFFE3F2FD);   // Fondo suave

  static ThemeData get light {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(backgroundColor: primaryBlue),
      colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
      useMaterial3: true,
    );
  }
}