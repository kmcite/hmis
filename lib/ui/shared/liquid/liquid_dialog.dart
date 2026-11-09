import 'package:flutter/material.dart';

import 'liquid_button.dart';
import 'liquid_icon_button.dart';
import 'liquid_surface.dart';
import 'liquid_tokens.dart';
import 'liquid_variant.dart';

Future<T?> showLiquidDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  double maxWidth = 420,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => LiquidDialog(maxWidth: maxWidth, child: child),
  );
}

class LiquidDialog extends StatelessWidget {
  const LiquidDialog({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 20),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LiquidSurface(
          variant: LiquidVariant.elevated,
          radius: LiquidTokens.radiusXl,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class LiquidDialogTitle extends StatelessWidget {
  const LiquidDialogTitle(this.text, {super.key, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: cs.primary, size: 22),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidDialogActions extends StatelessWidget {
  const LiquidDialogActions({
    super.key,
    required this.actions,
    this.spacing = 8,
  });

  final List<Widget> actions;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        spacing: spacing,
        children: [for (final action in actions) Expanded(child: action)],
      ),
    );
  }
}

class LiquidCloseHeader extends StatelessWidget {
  const LiquidCloseHeader({
    super.key,
    required this.title,
    this.onClose,
  });

  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LiquidIconButton(
          icon: Icons.close_rounded,
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          size: 40,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

/// Destructive secondary action styled for dialogs.
class LiquidDialogDestructiveButton extends StatelessWidget {
  const LiquidDialogDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return LiquidButton(
      onPressed: onPressed,
      style: LiquidButtonStyle.secondary,
      tint: error,
      expand: true,
      child: Text(label),
    );
  }
}
