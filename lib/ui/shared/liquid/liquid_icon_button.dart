import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_tokens.dart';
import 'liquid_variant.dart';

class LiquidIconButton extends StatelessWidget {
  const LiquidIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.tint,
    this.selected = false,
    this.size = 44,
    this.margin = const EdgeInsets.all(4),
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? tint;
  final bool selected;
  final double size;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = tint ?? cs.primary;

    final button = LiquidSurface(
      onTap: onPressed,
      variant: selected ? LiquidVariant.accent : LiquidVariant.surface,
      tint: color,
      selected: selected,
      radius: LiquidTokens.radiusMd,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: size * 0.45,
          color: selected ? color : cs.onSurfaceVariant,
        ),
      ),
    );

    final padded = Padding(padding: margin, child: button);

    if (tooltip == null) return padded;
    return Tooltip(message: tooltip!, child: padded);
  }
}
