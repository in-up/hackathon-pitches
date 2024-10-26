import 'package:flutter/material.dart';

class ColorConstants {
  // Primary Colors
  static const Color primary = Color(0xFF1E0E62);
  static const Color background = Color(0xFFfcfcfc);
  static const Color textSecondary = Color(0xFF60646C);

  // Status Colors
  static const Color statusNormal = Color(0xFF1E0E62);
  static const Color statusGood = Color(0xFF208368);
  static const Color statusFast = Color(0xFFCE2C31);

  // Shadow Colors
  static Color get shadowColor => primary.withOpacity(0.1);
}
