import 'package:flutter/material.dart';

/// Full-screen background color behind app content.
class LiquidCanvas extends StatelessWidget {
  const LiquidCanvas({super.key, required this.child});

  final Widget child;

  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: background(context), child: child);
  }
}
