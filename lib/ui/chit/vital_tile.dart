import 'package:flutter/material.dart';

class VitalTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool isBP;
  final double width;
  final Function(int) onDrag;
  final Function(int)? onSecondaryDrag;
  final Color accentColor;
  final bool isAbnormal;
  final Color abnormalColor;

  const VitalTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.width,
    this.isBP = false,
    required this.onDrag,
    this.onSecondaryDrag,
    this.accentColor = const Color(0xFF1A237E),
    this.isAbnormal = false,
    this.abnormalColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    double buffer1 = 0;
    double buffer2 = 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: width,
      height: 72,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isAbnormal ? abnormalColor.withOpacity(0.08) : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAbnormal ? abnormalColor.withOpacity(0.4) : colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isAbnormal ? abnormalColor : colorScheme.onSurfaceVariant,
                ),
              ),
              if (isAbnormal)
                Icon(Icons.warning_amber_rounded, size: 10, color: abnormalColor),
            ],
          ),
          Expanded(
            child: isBP
                ? Row(
                    children: [
                      _dragArea(theme, value.split('/')[0], (d) {
                        buffer1 += d;
                        if (buffer1.abs() > 10) {
                          onDrag((buffer1 / 10).round());
                          buffer1 = 0;
                        }
                      }, accentColor),
                      Text(
                        "/",
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.outlineVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _dragArea(theme, value.split('/')[1], (d) {
                        buffer2 += d;
                        if (buffer2.abs() > 10) {
                          onSecondaryDrag!((buffer2 / 10).round());
                          buffer2 = 0;
                        }
                      }, colorScheme.onSurface),
                    ],
                  )
                : _dragArea(theme, value, (d) {
                    buffer1 += d;
                    if (buffer1.abs() > 10) {
                      onDrag((buffer1 / 10).round());
                      buffer1 = 0;
                    }
                  }, colorScheme.onSurface),
          ),
          if (unit != null)
            Text(
              unit!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dragArea(ThemeData theme, String text, Function(double) onDelta, Color color) {
    return Expanded(
      child: GestureDetector(
        onHorizontalDragUpdate: (det) => onDelta(det.primaryDelta!),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
