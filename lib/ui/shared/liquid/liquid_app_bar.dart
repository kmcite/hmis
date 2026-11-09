import 'package:flutter/material.dart';

/// Transparent app bar aligned with liquid canvas backgrounds.
class LiquidAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LiquidAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: [
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
      leading: leading,
      centerTitle: centerTitle,
      bottom: bottom,
      actionsPadding: const EdgeInsets.only(right: 4),
    );
  }
}
