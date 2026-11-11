import 'package:flutter/material.dart';

import 'liquid_decoration.dart';
import 'liquid_theme.dart';
import 'liquid_variant.dart';

/// Primary building block: a tinted container.
class LiquidSurface extends StatelessWidget {
  const LiquidSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.variant = LiquidVariant.surface,
    this.tint,
    this.radius,
    this.selected = false,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final LiquidVariant variant;
  final Color? tint;
  final double? radius;
  final bool selected;
  final Clip clipBehavior;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidThemeData.of(context);
    final effectiveRadius = radius ?? theme.defaultRadius;

    final decoration = liquidDecoration(
      context,
      variant: variant,
      tint: tint,
      radius: effectiveRadius,
      selected: selected,
    );

    Widget core;
    if (onTap != null || onLongPress != null) {
      // Ink paints the decoration onto the Material so the InkWell splash
      // renders consistently above every variant (opaque or tinted).
      core = Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(effectiveRadius),
          clipBehavior: clipBehavior,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(effectiveRadius),
            child: Ink(
              decoration: decoration,
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ),
        ),
      );
    } else {
      core = DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      );
    }

    if (margin != null) {
      core = Padding(padding: margin!, child: core);
    }
    return core;
  }
}
