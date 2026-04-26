import 'package:flutter/material.dart';

class ChitChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Color? activeColor;

  const ChitChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = activeColor ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: RawChip(
        label: Text(label),
        selected: isSelected,
        onPressed: onTap,
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 16),
        deleteIconColor: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
        selectedColor: color,
        checkmarkColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? color : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        elevation: 0,
        pressElevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
