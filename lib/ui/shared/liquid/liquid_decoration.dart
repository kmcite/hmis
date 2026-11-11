import 'package:flutter/material.dart';

import 'liquid_variant.dart';

/// Builds a flat tinted surface: solid fill + border + shadow.
BoxDecoration liquidDecoration(
  BuildContext context, {
  LiquidVariant variant = LiquidVariant.surface,
  Color? tint,
  double radius = 16,
  bool selected = false,
  BorderSide? borderSide,
}) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = tint ?? cs.primary;

  Color color;
  Color border;
  List<BoxShadow> shadows;

  switch (variant) {
    case LiquidVariant.hero:
      color = accent;
      border = Colors.white.withValues(alpha: isDark ? 0.18 : 0.28);
      shadows = [
        BoxShadow(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.28),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
    case LiquidVariant.accent:
      color = accent.withValues(alpha: isDark ? 0.35 : 0.14);
      border = accent.withValues(alpha: isDark ? 0.45 : 0.35);
      shadows = [
        BoxShadow(
          color: accent.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    case LiquidVariant.elevated:
      color = cs.surfaceContainerHigh;
      border = cs.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.65);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
    case LiquidVariant.inset:
      color = cs.surfaceContainerHigh;
      border = cs.outline.withValues(alpha: isDark ? 0.5 : 0.45);
      shadows = const [];
    case LiquidVariant.surface:
      color = cs.surfaceContainerLow;
      border = cs.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.5);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
  }

  if (selected) {
    color = Color.lerp(color, accent, 0.45)!;
    border = accent.withValues(alpha: 0.85);
    shadows = [
      BoxShadow(
        color: accent.withValues(alpha: 0.28),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ];
  }

  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: borderSide?.color ?? border,
      width: borderSide?.width ?? (selected ? 1.5 : 1),
    ),
    boxShadow: shadows,
  );
}
