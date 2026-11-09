import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_tokens.dart';
import 'liquid_variant.dart';

class LiquidFab extends StatelessWidget {
  const LiquidFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.tint,
    this.extended = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final Color? tint;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = tint ?? cs.primary;

    final child = extended && label != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cs.onPrimary),
              const SizedBox(width: 8),
              Text(
                label!,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        : Icon(icon, color: cs.onPrimary);

    return LiquidSurface(
      onTap: onPressed,
      variant: LiquidVariant.hero,
      tint: color,
      radius: extended ? LiquidTokens.radiusXl : 28,
      padding: EdgeInsets.symmetric(
        horizontal: extended ? 20 : 0,
        vertical: extended ? 14 : 0,
      ),
      child: extended
          ? child
          : SizedBox(width: 56, height: 56, child: Center(child: child)),
    );
  }
}
