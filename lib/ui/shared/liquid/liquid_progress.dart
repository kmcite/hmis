import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_variant.dart';

class LiquidProgress extends StatelessWidget {
  const LiquidProgress({
    super.key,
    this.message,
    this.compact = false,
  });

  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final indicator = SizedBox(
      width: compact ? 28 : 36,
      height: compact ? 28 : 36,
      child: CircularProgressIndicator(
        strokeWidth: compact ? 2.5 : 3,
        color: cs.primary,
      ),
    );

    if (message == null) {
      return Center(child: indicator);
    }

    return Center(
      child: LiquidSurface(
        variant: LiquidVariant.surface,
        specular: false,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(height: 12),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
