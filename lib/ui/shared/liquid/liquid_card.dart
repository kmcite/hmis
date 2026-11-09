import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_variant.dart';

class LiquidCard extends StatelessWidget {
  const LiquidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.variant = LiquidVariant.elevated,
    this.tint,
    this.radius,
    this.specular,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final LiquidVariant variant;
  final Color? tint;
  final double? radius;
  final bool? specular;

  @override
  Widget build(BuildContext context) {
    return LiquidSurface(
      onTap: onTap,
      variant: variant,
      tint: tint,
      radius: radius,
      margin: margin,
      padding: padding,
      specular: specular,
      child: child,
    );
  }
}
