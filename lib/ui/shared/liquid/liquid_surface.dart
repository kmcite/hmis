import 'package:flutter/material.dart';

import 'liquid_decoration.dart';
import 'liquid_specular.dart';
import 'liquid_theme.dart';
import 'liquid_variant.dart';

/// Primary building block: a tinted, specular-trimmed container.
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
    this.specular,
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
  final bool? specular;
  final Clip clipBehavior;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = LiquidThemeData.of(context);
    final effectiveRadius = radius ?? theme.defaultRadius;
    final showSpecular = specular ?? theme.specularEnabled;

    final decoration = liquidDecoration(
      context,
      variant: variant,
      tint: tint,
      radius: effectiveRadius,
      selected: selected,
    );

    Widget core = DecoratedBox(
      decoration: decoration,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showSpecular)
            LiquidSpecular(radius: effectiveRadius, variant: variant),
          Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ],
      ),
    );

    if (margin != null) {
      core = Padding(padding: margin!, child: core);
    }

    if (onTap != null || onLongPress != null) {
      return Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(effectiveRadius),
            child: core,
          ),
        ),
      );
    }
    return core;
  }
}
