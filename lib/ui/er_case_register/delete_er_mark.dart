import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';
import 'package:hmis/ui/marksheet/er_mark_to_delete.dart';
import 'package:hmis/ui/marksheet/er_marks.dart';

class DeleteErMarkDialog extends StatefulWidget {
  final ErMark markToDelete;
  const DeleteErMarkDialog(this.markToDelete, {super.key});

  @override
  State<DeleteErMarkDialog> createState() => _DeleteErMarkDialogState();
}

class _DeleteErMarkDialogState extends State<DeleteErMarkDialog> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted)
        context.read<ErMarkToDeleteCubit>().onMarkToDeleteChanged(
          widget.markToDelete,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markToDelete = widget.markToDelete;
    final caseType = CaseType.values[markToDelete.caseType];
    final shift = DutyShift.values[markToDelete.shift];
    final typeColor = caseType.color;

    return AlertDialog(
      title: const Text('Delete Case'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this case? This action cannot be undone.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // ── Case summary card ──────────────────────────────────
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Case type banner
                    Row(
                      children: [
                        Icon(caseType.icon, size: 16, color: typeColor),
                        const SizedBox(width: 8),
                        Text(
                          caseType.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          shift.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Patient info rows
                    _DialogInfoRow(
                      icon: Icons.person_outline,
                      label: 'Patient',
                      value: markToDelete.patientName.isEmpty
                          ? 'Unknown'
                          : markToDelete.patientName,
                      dimmed: markToDelete.patientName.isEmpty,
                    ),
                    if (markToDelete.ageYears > 0) ...[
                      const SizedBox(height: 8),
                      _DialogInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Age',
                        value: '${markToDelete.ageYears} years',
                      ),
                    ],
                    if (markToDelete.remarks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _DialogInfoRow(
                        icon: Icons.notes_outlined,
                        label: 'Remarks',
                        value: markToDelete.remarks,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Warning notice ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will permanently remove the record.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<ErMarksBloc>().deleteMark(markToDelete);
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

// ─── DIALOG INFO ROW ─────────────────────────────────────────────────────────

class _DialogInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool dimmed;

  const _DialogInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.hintColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.hintColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: dimmed
                  ? theme.hintColor
                  : theme.textTheme.bodySmall?.color,
              fontStyle: dimmed ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

