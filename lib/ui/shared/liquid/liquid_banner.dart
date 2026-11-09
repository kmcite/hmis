import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_variant.dart';

class LiquidBanner extends StatelessWidget {
  const LiquidBanner({
    super.key,
    required this.message,
    this.icon,
    this.tint,
    this.action,
    this.margin,
  });

  final String message;
  final IconData? icon;
  final Color? tint;
  final Widget? action;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = tint ?? cs.primary;

    return LiquidSurface(
      variant: LiquidVariant.accent,
      tint: color,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
