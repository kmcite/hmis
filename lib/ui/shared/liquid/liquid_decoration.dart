import 'package:flutter/material.dart';

import 'liquid_variant.dart';

/// Builds a layered gradient + border + shadow surface (no backdrop blur).
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

  Color top;
  Color bottom;
  Color border;
  List<BoxShadow> shadows;

  switch (variant) {
    case LiquidVariant.hero:
      top = Color.lerp(accent, Colors.white, isDark ? 0.12 : 0.22)!;
      bottom = Color.lerp(accent, Colors.black, isDark ? 0.35 : 0.18)!;
      border = Colors.white.withValues(alpha: isDark ? 0.18 : 0.28);
      shadows = [
        BoxShadow(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.28),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
    case LiquidVariant.accent:
      final base = accent.withValues(alpha: isDark ? 0.35 : 0.14);
      top = Color.lerp(base, Colors.white, isDark ? 0.08 : 0.45)!;
      bottom = Color.lerp(base, Colors.black, isDark ? 0.12 : 0.06)!;
      border = accent.withValues(alpha: isDark ? 0.45 : 0.35);
      shadows = [
        BoxShadow(
          color: accent.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    case LiquidVariant.elevated:
      top = cs.surfaceContainerHigh;
      bottom = cs.surfaceContainer;
      border = cs.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.65);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
    case LiquidVariant.inset:
      top = cs.surfaceContainerLow;
      bottom = cs.surfaceContainerHighest.withValues(alpha: 0.85);
      border = cs.outlineVariant.withValues(alpha: 0.35);
      shadows = const [];
    case LiquidVariant.surface:
      top = cs.surfaceContainerLowest;
      bottom = cs.surfaceContainerLow;
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
    top = Color.lerp(top, accent, 0.55)!;
    bottom = Color.lerp(bottom, accent, 0.35)!;
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
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [top, bottom],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: borderSide?.color ?? border,
      width: borderSide?.width ?? (selected ? 1.5 : 1),
    ),
    boxShadow: shadows,
  );
}
