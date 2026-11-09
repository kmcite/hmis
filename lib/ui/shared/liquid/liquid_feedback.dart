import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_tokens.dart';
import 'liquid_variant.dart';

void showLiquidSnackBar(BuildContext context, String message, {IconData? icon}) {
  final cs = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: LiquidSurface(
        variant: LiquidVariant.elevated,
        radius: LiquidTokens.radiusMd,
        specular: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: cs.primary, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
