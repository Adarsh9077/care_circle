import 'package:flutter/material.dart';

/// CareCircle palette — calm, reassurance-first (not clinical/alarm-heavy).
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(
    0xFF3D6E63,
  ); // muted sage green — calm, trustworthy
  static const Color primaryLight = Color(0xFFDCEAE5);
  static const Color primaryDark = Color(0xFF25443C);

  // Status semantics (avoid pure red/green only — pair with icon/text per accessibility requirement)
  static const Color statusGood = Color(0xFF2E7D32);
  static const Color statusAttention = Color(0xFFB8860B);
  static const Color statusUrgent = Color(0xFFC62828);
  static const Color statusUnknown = Color(0xFF757575);

  // Neutrals
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0DE);
  static const Color textPrimary = Color(0xFF1C1C1A);
  static const Color textSecondary = Color(0xFF5F5F5B);
  static const Color textDisabled = Color(0xFFA0A09C);

  // Privacy / sharing indicator
  static const Color privacyBadgeBg = Color(0xFFEDEDEA);
  static const Color privacyBadgeText = Color(0xFF57574F);

  // Feedback
  static const Color error = Color(0xFFB3261E);
  static const Color errorBg = Color(0xFFFBEAE9);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB8860B);

  static const Color divider = Color(0xFFE8E8E5);
  static const Color shimmerBase = Color(0xFFE6E6E3);
  static const Color shimmerHighlight = Color(0xFFF4F4F2);
}
