import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const Color primary = Color(0xFF00C896);
  static const Color primaryLight = Color(0xFFE6FAF4);
  static const Color primaryGradientEnd = Color(0xFF00D7A0);

  // Secondary
  static const Color secondary = Color(0xFF6D5EF4);
  static const Color secondaryLight = Color(0xFFEDEBFE);

  // Accent
  static const Color accent = Color(0xFFFF7FBF);
  static const Color accentLight = Color(0xFFFFE4F3);

  // Backgrounds
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Divider / border
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE5E7EB);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF00C896);

  // Compatibility score tiers
  static const Color scoreHigh = Color(0xFF00C896);    // 80–100
  static const Color scoreMedium = Color(0xFFF59E0B);  // 50–79
  static const Color scoreLow = Color(0xFF9CA3AF);     // 0–49

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF00C896), Color(0xFF00D7A0)];
  static const List<Color> premiumGradient = [Color(0xFF6D5EF4), Color(0xFFFF7FBF)];

  // Swipe feedback overlays
  static const Color swipePass = Color(0xFFF59E0B);
  static const Color swipeLike = Color(0xFF00C896);
  static const Color swipeSuperLike = Color(0xFF6D5EF4);

  // Chat bubbles
  static const Color messageSent = Color(0xFFDDF8F0);
  static const Color messageReceived = Color(0xFFF3F4F6);

  // Bottom nav
  static const Color navActive = Color(0xFF00C896);
  static const Color navInactive = Color(0xFF9CA3AF);

  // Map
  static const Color mapMarkerBorder = Color(0xFF00C896);
  static const Color mapCluster = Color(0xFF00C896);

  // Utility
  static const Color transparent = Color(0x00000000);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}
