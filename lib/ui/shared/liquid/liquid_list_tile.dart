import 'package:flutter/material.dart';

import 'liquid_surface.dart';
import 'liquid_variant.dart';

class LiquidListTile extends StatelessWidget {
  const LiquidListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.tint,
    this.variant = LiquidVariant.surface,
    this.dense = false,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? tint;
  final LiquidVariant variant;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidSurface(
      onTap: onTap,
      variant: variant,
      tint: tint,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: dense ? 10 : 14,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: tint ?? cs.primary),
              child: leading!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
