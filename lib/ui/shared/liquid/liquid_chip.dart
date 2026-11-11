import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_variant.dart';

class LiquidChip extends StatelessWidget {
  const LiquidChip({
    super.key,
    required this.label,
    this.icon,
    this.tint,
    this.dense = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? tint;
  final bool dense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = tint ?? cs.primary;
    return LiquidSurface(
      onTap: onTap,
      variant: LiquidVariant.inset,
      tint: color,
      radius: dense ? 8 : 10,
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: color),
            SizedBox(width: dense ? 4 : 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
