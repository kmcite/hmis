import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_tokens.dart';
import 'liquid_variant.dart';

enum LiquidButtonStyle { primary, secondary, plain }

class LiquidButton extends StatelessWidget {
  const LiquidButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.style = LiquidButtonStyle.primary,
    this.tint,
    this.size = LiquidControlSize.standard,
    this.expand = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;
  final LiquidButtonStyle style;
  final Color? tint;
  final LiquidControlSize size;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = tint ?? cs.primary;
    final enabled = onPressed != null;
    final radius = LiquidTokens.radiusFor(size);

    final (variant, foreground) = switch (style) {
      LiquidButtonStyle.primary => (LiquidVariant.hero, cs.onPrimary),
      LiquidButtonStyle.secondary => (LiquidVariant.accent, color),
      LiquidButtonStyle.plain => (LiquidVariant.surface, cs.onSurface),
    };

    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: foreground,
        );

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expand ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              size: size == LiquidControlSize.compact ? 18 : 20,
              color: labelStyle?.color,
            ),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        DefaultTextStyle(style: labelStyle ?? const TextStyle(), child: child),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: LiquidSurface(
        onTap: onPressed,
        variant: variant,
        tint: style == LiquidButtonStyle.primary ? color : tint,
        radius: radius,
        padding: LiquidTokens.paddingFor(size),
        child: content,
      ),
    );
  }
}
