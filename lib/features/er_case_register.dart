import 'package:flutter/material.dart';
import 'package:hmis/domain/er_mark.dart';
import 'package:hmis/features/delete_er_mark.dart';
import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/bussiness/navigation.dart';
import 'package:hmis/features/case_page.dart';
import 'package:hmis/utils/redux.dart';

class ErCaseRegister extends UI {
  const ErCaseRegister({super.key});

  @override
  Widget build(BuildContext context) {
    final marks = state.marks.all
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      ); // Sort by newest first

    return Scaffold(
      appBar: AppBar(
        title: Text('ER Case Register (${marks.length})'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: marks.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                height: 8,
                thickness: 2,
                color: Colors.transparent,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: marks.length,
              itemBuilder: (context, index) {
                return _ErMarkTile(marks[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No cases recorded',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding cases from the marksheet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErMarkTile extends StatelessWidget {
  final ErMark mark;

  const _ErMarkTile(this.mark);

  @override
  Widget build(BuildContext context) {
    final shift = DutyShift.values[mark.shift];
    final caseType = CaseType.values[mark.caseType];

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with case type and shift
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCaseTypeColor(caseType),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    caseType.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getShiftLabel(shift),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => dispatch(
                    ShowDialog(CasePage(mark)),
                  ),
                  icon: Icon(Icons.edit_document),
                ),
                IconButton(
                  onPressed: () {
                    dispatch(ShowDialog(DeleteErMarkDialog()));
                    dispatch(MarkToDeleteAction(mark));
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  tooltip: 'Delete Case',
                ),
              ],
            ),

            // Date information
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(mark.date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(mark.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            // Patient details (if available)
            if (mark.patientName.isNotEmpty || mark.ageYears > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPatientInfo(mark),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],

            // Remarks (if available)
            if (mark.remarks.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      mark.remarks,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

  String _getPatientInfo(ErMark mark) {
    final parts = <String>[];
    if (mark.patientName.isNotEmpty) {
      parts.add(mark.patientName);
    }
    if (mark.ageYears > 0) {
      parts.add('${mark.ageYears}y');
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Patient details not recorded';
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
}
