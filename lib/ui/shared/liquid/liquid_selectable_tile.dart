import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_variant.dart';

/// Icon + label tile for grids and segmented pickers (shift, case type, …).
class LiquidSelectableTile extends StatelessWidget {
  const LiquidSelectableTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tint,
    this.radius = 14,
    this.specular = false,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? tint;
  final double radius;
  final bool specular;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = tint ?? cs.primary;
    final fg = selected ? accent : cs.onSurfaceVariant;

    return LiquidSurface(
      onTap: onTap,
      variant: selected ? LiquidVariant.accent : LiquidVariant.surface,
      tint: accent,
      selected: selected,
      radius: radius,
      specular: specular,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: radius >= 16 ? 28 : 22,
              color: fg,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: icon != null ? 12 : 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: fg,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
