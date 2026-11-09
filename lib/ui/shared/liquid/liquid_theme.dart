import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'liquid_tokens.dart';

/// Optional overrides layered on [ThemeData.colorScheme] for liquid widgets.
class LiquidThemeData {
  const LiquidThemeData({
    this.defaultRadius = LiquidTokens.radiusLg,
    this.specularEnabled = true,
    this.tapScale = 0.98,
  });

  final double defaultRadius;
  final bool specularEnabled;
  final double tapScale;

  LiquidThemeData copyWith({
    double? defaultRadius,
    bool? specularEnabled,
    double? tapScale,
  }) {
    return LiquidThemeData(
      defaultRadius: defaultRadius ?? this.defaultRadius,
      specularEnabled: specularEnabled ?? this.specularEnabled,
      tapScale: tapScale ?? this.tapScale,
    );
  }

  static LiquidThemeData of(BuildContext context) {
    final ext = Theme.of(context).extension<LiquidTheme>();
    return ext?.data ?? const LiquidThemeData();
  }
}

class LiquidTheme extends ThemeExtension<LiquidTheme> {
  const LiquidTheme({this.data = const LiquidThemeData()});

  final LiquidThemeData data;

  @override
  LiquidTheme copyWith({LiquidThemeData? data}) {
    return LiquidTheme(data: data ?? this.data);
  }

  @override
  LiquidTheme lerp(covariant ThemeExtension<LiquidTheme>? other, double t) {
    if (other is! LiquidTheme) return this;
    return LiquidTheme(
      data: LiquidThemeData(
        defaultRadius:
            lerpDouble(data.defaultRadius, other.data.defaultRadius, t)!,
        specularEnabled:
            t < 0.5 ? data.specularEnabled : other.data.specularEnabled,
        tapScale: lerpDouble(data.tapScale, other.data.tapScale, t)!,
      ),
    );
  }
}
