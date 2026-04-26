import 'package:flutter/material.dart';

class CustomChitHeader extends StatelessWidget {
  final TextEditingController nameController;
  final bool isMale;
  final int age;
  final VoidCallback onGenderToggle;
  final Function(int) onAgeChanged;

  const CustomChitHeader({
    super.key,
    required this.nameController,
    required this.isMale,
    required this.age,
    required this.onGenderToggle,
    required this.onAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    double dragBuffer = 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: "Patient Name",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onGenderToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMale ? colorScheme.primaryContainer : Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMale ? Icons.male : Icons.female,
                        size: 14,
                        color: isMale ? colorScheme.primary : Colors.pink[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMale ? "M" : "F",
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isMale ? colorScheme.primary : Colors.pink[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (det) {
                  dragBuffer += det.primaryDelta!;
                  if (dragBuffer.abs() > 15) {
                    onAgeChanged((age + (dragBuffer / 15).round()).clamp(0, 120));
                    dragBuffer = 0;
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.unfold_more, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      "$age YRS",
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Text(
                "MTI THQ HOSPITAL".toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
