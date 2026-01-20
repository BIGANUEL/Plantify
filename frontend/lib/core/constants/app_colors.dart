import 'package:flutter/material.dart';

/// Consistent color scheme matching Plantify design
/// Color combination: Green (primary) + Brown (earth) + Teal (water) + Amber (sun)
class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenLight = Color(0xFF66BB6A);
  static const Color primaryGreenDark = Color(0xFF45A049);
  
  static const Color earthBrown = Color(0xFF8B6F47);
  static const Color earthBrownLight = Color(0xFFA68B6F);
  static const Color earthBrownDark = Color(0xFF6B5433);
  
  static const Color waterTeal = Color(0xFF14B8A6);
  static const Color waterTealLight = Color(0xFF5EEAD4);
  static const Color waterTealDark = Color(0xFF0D9488);
  
  static const Color sunAmber = Color(0xFFF59E0B);
  static const Color sunAmberLight = Color(0xFFFCD34D);
  static const Color sunAmberDark = Color(0xFFD97706);
  
  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusGreen = Color(0xFF10B981);
  static const Color statusOrange = Color(0xFFF59E0B);
  
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLightGray = Color(0xFFF8FAFC);
  static const Color backgroundLightGreen = Color(0xFFE8F5E9);
  static const Color backgroundWarmBeige = Color(0xFFF5F1EB);
  
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundDarkGray = Color(0xFF1E1E1E);
  static const Color backgroundDarkCard = Color(0xFF2D2D2D);
  
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF64748B);
  static const Color textGray = Color(0xFF94A3B8);
  
  static const Color textDarkMode = Color(0xFFE5E5E5);
  static const Color textDarkModeLight = Color(0xFFB0B0B0);
  
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  
  static const Color borderDark = Color(0xFF3A3A3A);
  
  static const Color actionBlue = Color(0xFF14B8A6);
  static const Color actionGreen = Color(0xFF4CAF50);
  static const Color actionBrown = Color(0xFF8B6F47);
  
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardLightGreen = Color(0xFFE8F5E9);
  static const Color cardWarmBeige = Color(0xFFF5F1EB);
  
  static const Color cardBackgroundDark = Color(0xFF2D2D2D);
  
  static List<Color> get primaryGradient => [
    primaryGreen,
    primaryGreenLight,
    waterTeal,
  ];
  
  static List<Color> get sunsetGradient => [
    sunAmber,
    sunAmberLight,
    const Color(0xFFFF6B6B),
  ];
  
  static List<Color> get oceanGradient => [
    waterTeal,
    waterTealLight,
    const Color(0xFF3B82F6),
  ];
  
  static List<Color> get earthGradient => [
    earthBrown,
    earthBrownLight,
    primaryGreen,
  ];
  
  static List<Color> get backgroundGradientLight => [
    const Color(0xFFF0FDF4), // Very light green
    const Color(0xFFF8FAFC), // Off white
    const Color(0xFFECFDF5), // Mint tint
  ];
  
  static List<Color> get backgroundGradientDark => [
    const Color(0xFF0A1F0A), // Very dark green
    const Color(0xFF121212), // Dark gray
    const Color(0xFF1A2E1A),
  ];

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLightGray;
  }
  
  static Color getCardBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardBackgroundDark
        : cardBackground;
  }
  
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textDarkMode
        : textDark;
  }
  
  static Color getTextLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textDarkModeLight
        : textLight;
  }
  
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : borderLight;
  }
}

