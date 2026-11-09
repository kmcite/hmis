import 'package:flutter/material.dart';

import 'liquid_tokens.dart';
import 'liquid_variant.dart';

/// Top-edge highlight mimicking glass refraction without blur.
class LiquidSpecular extends StatelessWidget {
  const LiquidSpecular({
    super.key,
    required this.radius,
    required this.variant,
  });

  final double radius;
  final LiquidVariant variant;

  @override
  Widget build(BuildContext context) {
    final peakAlpha = variant == LiquidVariant.hero
        ? LiquidTokens.specularHero
        : LiquidTokens.specularDefault;

    return Positioned(
      left: 1,
      right: 1,
      top: 1,
      height: radius,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(radius > 1 ? radius - 1 : 0),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: peakAlpha),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
