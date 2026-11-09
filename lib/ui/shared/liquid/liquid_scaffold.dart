import 'package:flutter/material.dart';

import 'liquid_canvas.dart';

/// Scaffold with transparent background over [LiquidCanvas] styling.
class LiquidScaffold extends StatelessWidget {
  const LiquidScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Wraps [child] with canvas gradient when not already under [LiquidCanvas].
class LiquidPage extends StatelessWidget {
  const LiquidPage({super.key, required this.child, this.applyCanvas = false});

  final Widget child;
  final bool applyCanvas;

  @override
  Widget build(BuildContext context) {
    if (!applyCanvas) return child;
    return LiquidCanvas(child: child);
  }
}
