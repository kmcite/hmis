import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_variant.dart';

class LiquidDivider extends StatelessWidget {
  const LiquidDivider({
    super.key,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.indent = 0,
    this.endIndent = 0,
  });

  final EdgeInsetsGeometry margin;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: margin,
      child: LiquidSurface(
        variant: LiquidVariant.inset,
        radius: 1,
        specular: false,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 1,
          width: double.infinity,
          child: ColoredBox(color: cs.outlineVariant.withValues(alpha: 0.35)),
        ),
      ),
    );
  }
}
