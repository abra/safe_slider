import 'package:flutter/material.dart';

abstract final class SafeSliderDefaults {
  // Colors
  static const Color activeColor = Color(0xFF323A46);
  static const Color inactiveColor = Color(0xFFE1E1E1);
  static const Color warningColor = Color(0xFFFF5959);
  static const Color thumbFillColor = Colors.white;

  // Dimensions
  static const double thumbSize = 50.0;
  static const double strokeWidth = 2.0;
  static const double labelFontSize = 18.0;
  static const int labelDecimalPlaces = 2;

  // Font
  static const String fontFamily = 'DroidSansMono';
  static const FontWeight labelFontWeight = FontWeight.w700;

  // Range
  static const double min = 0.0;
  static const double max = 1.0;

  // Gesture
  static const double angleThreshold = 25.0;
  static const double maxStretchRatio = 1.8;

  // Animation
  static const Duration snapDuration = Duration(milliseconds: 150);
  static const Duration bounceDuration = Duration(milliseconds: 1100);
  static const Duration unlockDelay = Duration(milliseconds: 300);
  static const double elasticPeriod = 0.4;
  static const double elasticBounceFactor = 0.5;
}
