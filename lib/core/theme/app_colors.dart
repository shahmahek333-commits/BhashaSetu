import 'package:flutter/material.dart';

/// Color palette for BhasaSetu.
/// Adheres to the pastel educational theme:
/// - Pastel lavender
/// - Pastel blue
/// - Pastel green
/// - Soft cream background
/// - Pure white card surfaces
/// - Dark charcoal typography with accessible contrast
abstract final class AppColors {
  // Primary: Pastel Lavender
  static const Color primaryLavender = Color(0xFF6E5DA0);
  static const Color lavenderLight = Color(0xFFECE7F6);
  static const Color lavenderMedium = Color(0xFF9E8ECA);
  static const Color lavenderDark = Color(0xFF4D3F75);

  // Secondary: Pastel Blue
  static const Color secondaryBlue = Color(0xFF467A9E);
  static const Color blueLight = Color(0xFFE2EEF7);
  static const Color blueMedium = Color(0xFF7FAED1);
  static const Color blueDark = Color(0xFF2F546E);

  // Tertiary: Pastel Green
  static const Color tertiaryGreen = Color(0xFF45855E);
  static const Color greenLight = Color(0xFFE0F2E8);
  static const Color greenMedium = Color(0xFF70B88E);
  static const Color greenDark = Color(0xFF2A593D);

  // Background & Surfaces
  static const Color softCream = Color(0xFFFBF9F5);
  static const Color creamAlt = Color(0xFFF3EFE7);
  static const Color whiteCard = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE7E3DB);

  // Typography / Dark Charcoal
  static const Color darkCharcoal = Color(0xFF1E2126);
  static const Color charcoalMuted = Color(0xFF555B66);
  static const Color charcoalLight = Color(0xFF7E8490);

  // Status & Feedback
  static const Color statusSuccess = Color(0xFF388E5E);
  static const Color statusWarning = Color(0xFFD9822B);
  static const Color statusError = Color(0xFFC94A4A);
  static const Color statusInfo = Color(0xFF3B7BA8);
}
