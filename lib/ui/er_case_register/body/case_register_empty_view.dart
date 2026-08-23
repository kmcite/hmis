import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: theme.disabledColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cases recorded',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Cases saved from the chit or marksheet appear here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }
}
