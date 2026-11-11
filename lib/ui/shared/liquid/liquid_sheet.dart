import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_tokens.dart';
import 'liquid_variant.dart';

Future<T?> showLiquidSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (ctx) => LiquidSheet(child: child),
  );
}

class LiquidSheet extends StatelessWidget {
  const LiquidSheet({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: LiquidSurface(
        variant: LiquidVariant.elevated,
        radius: LiquidTokens.radiusXl,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: padding ??
            const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
