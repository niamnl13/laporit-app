import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0A2647);     
  static const Color primaryDark = Color(0xFF1E3A8A);   // ← Diubah agar sesuai gradient
  static const Color accent = Color(0xFF00B4D8);        // Teal accent

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1E2937);
  static const Color textSecondary = Color(0xFF64748B);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // Gradient untuk Logo
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF0A2647),
    ],
  );
}