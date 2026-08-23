import 'package:flutter/material.dart';
import 'package:hmis/models/models.dart';
import 'package:hmis/models/presentation.dart';
import 'package:hmis/ui/dialogs/delete_er_mark.dart';
import 'package:hmis/utils/datetime.dart';
import 'package:hmis/utils/router.dart';
import 'package:navigation/navigation.dart';

class ErMarkTile extends StatelessWidget {
  final Mark mark;
  const ErMarkTile(this.mark);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shift = mark.shift;
    final caseType = mark.caseType;
    final color = caseType.color;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => router.push(NewChitRoute()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(caseType.icon, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          caseType.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shift.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => router.push(NewChitRoute()),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        context.pushDialog(DeleteErMarkDialog(mark)),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Patient info
              Text(
                mark.patientName?.isEmpty ?? true
                    ? 'Anonymous Patient'
                    : mark.patientName!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mark.patientName?.isEmpty ?? true
                      ? theme.disabledColor
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              // Meta row — real wall-clock createdAt + age
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    // Real datetime (wall-clock, never altered)
                    mark.createdAt?.formattedDateTime() ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  if ((mark.ageYears ?? 0) > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mark.info,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
              if (mark.remarks?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  mark.remarks!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
