import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/patient_draft_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/patients_repository.dart';

class DeletePatientDialog extends StatelessWidget {
  const DeletePatientDialog(this.patientToDelete, {super.key});

  final Patient patientToDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caseType = patientToDelete.caseType;
    final shift = patientToDelete.shift;
    final typeColor = caseType.color;
    final cs = theme.colorScheme;

    return LiquidDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiquidDialogTitle('Delete case', icon: Icons.delete_outline),
          Text(
            'This cannot be undone. The record will be removed from this device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LiquidCard(
            variant: LiquidVariant.inset,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    LiquidChip(label: shift.label, dense: true),
                  ],
                ),
                const SizedBox(height: 12),
                _DialogInfoRow(
                  icon: Icons.person_outline,
                  label: 'Patient',
                  value: patientToDelete.patientName?.isEmpty ?? true
                      ? 'Unknown'
                      : patientToDelete.patientName!,
                  dimmed: patientToDelete.patientName?.isEmpty ?? true,
                ),
                if ((patientToDelete.ageYears ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  _DialogInfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Age',
                    value: '${patientToDelete.ageYears} years',
                  ),
                ],
                if (patientToDelete.remarks?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  _DialogInfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Remarks',
                    value: patientToDelete.remarks ?? '',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          LiquidSurface(
            variant: LiquidVariant.accent,
            tint: cs.error,
            radius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Permanent deletion',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LiquidDialogActions(
            actions: [
              LiquidButton(
                onPressed: () => Navigator.of(context).pop(),
                style: LiquidButtonStyle.plain,
                child: const Text('Cancel'),
              ),
              LiquidDialogDestructiveButton(
                label: 'Delete',
                onPressed: () async {
                  await context.read<PatientsRepository>().remove(patientToDelete.id);
                  final draft = context.read<PatientDraftCubit>();
                  if (draft.state.selectedId == patientToDelete.id) {
                    draft.clearSelection();
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
        Icon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: dimmed
                  ? theme.colorScheme.outline
                  : theme.textTheme.bodySmall?.color,
              fontStyle: dimmed ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}
