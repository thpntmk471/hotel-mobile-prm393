import 'package:flutter/material.dart';

class AppColors {
  // Brand color (Deep Emerald Green - matching Web BE)
  static const Color primary = Color(0xFF1B5E4F);
  static const Color primaryLight = Color(0xFFE8F2EF);
  static const Color primaryDark = Color(0xFF123F35);

  // Background & Surface
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color inputBg = Color(0xFFF9FAFB);

  // Status Colors (Matching Web Status Chips)
  static const Color statusActiveBg = Color(0xFFDCFCE7);
  static const Color statusActiveText = Color(0xFF15803D);

  static const Color statusWarningBg = Color(0xFFFEF3C7);
  static const Color statusWarningText = Color(0xFFB45309);

  static const Color statusBlueBg = Color(0xFFDBEAFE);
  static const Color statusBlueText = Color(0xFF1D4ED8);

  static const Color statusGrayBg = Color(0xFFF3F4F6);
  static const Color statusGrayText = Color(0xFF4B5563);

  // Luxury Accents (5-Star Hotel Identity)
  static const Color gold = Color(0xFFC5A059);
  static const Color goldLight = Color(0xFFFDF8E7);
  static const Color goldDark = Color(0xFF9E7D3B);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E4F), Color(0xFF113D33)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFAA8020)],
  );

  static const Color error = Color(0xFFDC2626);
}

