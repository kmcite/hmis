import 'package:hmis/main.dart';
import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/bussiness/navigation.dart';
import 'package:hmis/utils/redux.dart';
import 'package:hmis/domain/er_mark.dart';

class DeleteErMarkDialog extends UI {
  const DeleteErMarkDialog({super.key});

  @override
  Widget build(context) {
    final markToDelete = store.state.marks.markToDelete;

    if (markToDelete == null) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Delete Case'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you sure you want to delete this case? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildCaseDetails(context, markToDelete),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => dispatch(NavigateBack()),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            dispatch(DeleteMark(markToDelete));
            dispatch(NavigateBack());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Delete'),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
    );
  }

  Widget _buildCaseDetails(BuildContext context, ErMark mark) {
    final caseType = CaseType.values[mark.caseType];
    final shift = DutyShift.values[mark.shift];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCaseTypeColor(caseType),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  caseType.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getShiftLabel(shift),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (mark.patientName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  mark.patientName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (mark.ageYears > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${mark.ageYears}y)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(mark.date),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getShiftLabel(DutyShift shift) {
    switch (shift) {
      case DutyShift.morning:
        return 'Morning';
      case DutyShift.evening:
        return 'Evening';
      case DutyShift.night:
        return 'Night';
    }
  }

  Color _getCaseTypeColor(CaseType caseType) {
    switch (caseType) {
      case CaseType.medical:
        return Colors.blue;
      case CaseType.surgical:
        return Colors.green;
      case CaseType.pediatrics:
        return Colors.purple;
      case CaseType.minorOt:
        return Colors.orange;
      case CaseType.rta:
        return Colors.red;
      case CaseType.dogBite:
        return Colors.brown;
      case CaseType.mlc:
        return Colors.indigo;
      case CaseType.postmortem:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    dispatch(MarkToDeleteAction());
  }
}
