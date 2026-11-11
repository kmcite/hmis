import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/patient_draft_cubit.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/shared/dialogs/delete_patient.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';
import 'package:hmis/ui/patient/patient_details_screen.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/shared/widgets/sheet_arrival_banner.dart';
import 'package:hmis/services/datetime.dart';

class PatientTile extends StatelessWidget {
  final Patient patient;
  const PatientTile(this.patient);

  void _openPatient(BuildContext context) {
    context.read<PatientDraftCubit>().open(patient.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewChitScreen()),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientDetailsScreen(patientId: patient.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shift = patient.shift;
    final caseType = patient.caseType;
    final color = caseType.color;

    return LiquidCard(
      onTap: () => _openDetails(context),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  LiquidChip(
                    label: caseType.label,
                    icon: caseType.icon,
                    tint: color,
                    dense: true,
                  ),
                  const SizedBox(width: 8),
                  LiquidChip(
                    label: shift.label,
                    tint: theme.colorScheme.secondary,
                    dense: true,
                  ),
                  if (patient.needsDetails) ...[
                    const SizedBox(width: 8),
                    LiquidChip(
                      label: 'Needs details',
                      icon: Icons.edit_note,
                      tint: theme.colorScheme.tertiary,
                      dense: true,
                    ),
                  ],
                  const Spacer(),
                  LiquidIconButton(
                    size: 36,
                    icon: Icons.edit_outlined,
                    tint: theme.colorScheme.primary,
                    onPressed: () => _openPatient(context),
                  ),
                  LiquidIconButton(
                    size: 36,
                    icon: Icons.delete_outline,
                    tint: theme.colorScheme.error,
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => DeletePatientDialog(patient),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Patient info
              Text(
                patient.patientName?.isEmpty ?? true
                    ? 'Anonymous Patient'
                    : patient.patientName!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: patient.patientName?.isEmpty ?? true
                      ? theme.disabledColor
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              PatientDateChips(patient: patient),
              const SizedBox(height: 8),
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
                    patient.createdAt?.formattedDateTime() ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  if ((patient.ageYears ?? 0) > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      patient.info,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
              if (patient.remarks?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  patient.remarks!,
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
    );
  }
}
