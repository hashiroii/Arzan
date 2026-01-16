import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Yellow Theme
  static const Color primaryYellow = Color(0xFFFFD700); // Gold
  static const Color primaryYellowDark = Color(0xFFD4AF37); // Dark Gold
  static const Color primaryYellowLight = Color(0xFFFFF44F); // Light Gold

  // Accent Colors
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = accentGreen;
  static const Color error = accentRed;
  static const Color warning = accentOrange;
  static const Color info = accentBlue;

  // Vote Colors
  static const Color upvote = Color(0xFFFF6B6B);
  static const Color downvote = Color(0xFF4ECDC4);
}
