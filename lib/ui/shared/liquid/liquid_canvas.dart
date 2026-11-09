import 'package:flutter/material.dart';

/// Full-screen ambient gradient behind app content (replaces flat scaffold fill).
class LiquidCanvas extends StatelessWidget {
  const LiquidCanvas({super.key, required this.child});

  final Widget child;

  static BoxDecoration background(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                cs.surface,
                Color.lerp(cs.surface, cs.primary, 0.12)!,
                cs.surfaceContainerLow,
              ]
            : [
                Color.lerp(cs.surface, cs.primaryContainer, 0.35)!,
                cs.surface,
                Color.lerp(cs.surface, cs.tertiaryContainer, 0.25)!,
              ],
        stops: const [0, 0.55, 1],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: background(context),
      child: child,
    );
  }
}
