import 'package:flutter/material.dart';

/// Shared radii and motion for the liquid design system.
abstract final class LiquidTokens {
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  static const Duration pressDuration = Duration(milliseconds: 120);

  static double radiusFor(LiquidControlSize size) => switch (size) {
        LiquidControlSize.compact => radiusSm,
        LiquidControlSize.standard => radiusMd,
        LiquidControlSize.large => radiusLg,
      };

  static EdgeInsets paddingFor(LiquidControlSize size) => switch (size) {
        LiquidControlSize.compact =>
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        LiquidControlSize.standard =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        LiquidControlSize.large =>
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      };
}

enum LiquidControlSize { compact, standard, large }
