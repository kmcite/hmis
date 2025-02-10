import 'package:hmis/main.dart';
import 'package:hmis/user_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final TextStyle? titleTextStyle;
  final Widget? action;
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.action,
    this.actions,
    this.backgroundColor,
    this.elevation = 4.0,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Row(
        children: [
          Text(
            title,
            style: titleTextStyle ?? theme.textTheme.titleLarge,
          ),
          const Spacer(),
        ],
      ),
      leading: leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              context.pop();
            },
          ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: action ??
              IconButton.filledTonal(
                icon: const Icon(Icons.verified_user),
                onPressed: () {
                  context.of<RouterBloc>().toRouteByName(UserPage.name);
                },
              ),
        ),
        ...?actions
      ],
      backgroundColor: backgroundColor ?? colorScheme.primary,
      elevation: elevation,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16.0),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
