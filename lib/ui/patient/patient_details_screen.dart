import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/patient_draft_cubit.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/patients_repository.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';
import 'package:hmis/ui/shared/dialogs/delete_patient.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/shared/widgets/sheet_arrival_banner.dart';
import 'package:intl/intl.dart';

/// Read-only view of a stored [Patient] with edit/delete actions.
class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key, required this.patientId});

  final String patientId;

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Patient? _patient;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final patient = await context.read<PatientsRepository>().fetchOne(
      widget.patientId,
    );
    if (!mounted) return;
    setState(() {
      _patient = patient;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    context.read<PatientDraftCubit>().open(widget.patientId);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewChitScreen()),
    );
    if (mounted) await _load();
  }

  Future<void> _delete() async {
    final patient = _patient;
    if (patient == null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => DeletePatientDialog(patient),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final patient = _patient;

    return LiquidScaffold(
      appBar: LiquidAppBar(
        title: 'Patient details',
        centerTitle: true,
        actions: [
          if (patient != null)
            LiquidIconButton(
              icon: Icons.edit_outlined,
              tooltip: 'Edit',
              onPressed: _edit,
            ),
        ],
      ),
      body: _loading
          ? const LiquidProgress(message: 'Loading patient…')
          : patient == null
          ? Center(
              child: Text(
                'Patient not found',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : _DetailsBody(patient: patient, onDelete: _delete),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.patient, required this.onDelete});

  final Patient patient;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        LiquidCard(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      patient.patientName?.trim().isNotEmpty == true
                          ? patient.patientName!
                          : 'Anonymous patient',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (patient.needsDetails)
                    LiquidChip(
                      label: 'Needs details',
                      icon: Icons.edit_note,
                      tint: cs.tertiary,
                      dense: true,
                    ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  LiquidChip(
                    label: patient.caseType.label,
                    icon: patient.caseType.icon,
                    tint: patient.caseType.color,
                    dense: true,
                  ),
                  LiquidChip(
                    label: patient.shift.label,
                    icon: patient.shift.icon,
                    tint: cs.secondary,
                    dense: true,
                  ),
                ],
              ),
              PatientDateChips(patient: patient),
              if (patient.createdAt != null)
                Text(
                  'Arrived ${DateFormat('d MMM yyyy · HH:mm').format(patient.createdAt!.toLocal())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiquidCard(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const LiquidSectionHeader(
                icon: Icons.person_outline,
                label: 'Patient info',
              ),
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: patient.ageYears != null
                    ? '${patient.ageYears} years'
                    : 'Not recorded',
                dimmed: patient.ageYears == null,
              ),
              _InfoRow(
                icon: Icons.wc_outlined,
                label: 'Sex',
                value: switch (patient.isMale) {
                  true => 'Male',
                  false => 'Female',
                  null => 'Not recorded',
                },
                dimmed: patient.isMale == null,
              ),
              _InfoRow(
                icon: Icons.notes_outlined,
                label: 'Remarks',
                value: patient.remarks?.trim().isNotEmpty == true
                    ? patient.remarks!
                    : 'Not recorded',
                dimmed: patient.remarks?.trim().isNotEmpty != true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiquidCard(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const LiquidSectionHeader(
                icon: Icons.assignment_outlined,
                label: 'Clinical notes',
              ),
              _NoteSection(label: 'Hx — history taking', text: patient.history),
              _NoteSection(
                label: 'O/E — on examination',
                text: patient.examination,
              ),
              _NoteSection(label: 'Management', text: patient.management),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LiquidButton(
          onPressed: onDelete,
          style: LiquidButtonStyle.plain,
          expand: true,
          icon: const Icon(Icons.delete_outline),
          child: const Text('Delete record'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.dimmed = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.outline),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: dimmed ? cs.outline : cs.onSurface,
              fontStyle: dimmed ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection({required this.label, required this.text});

  final String label;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasText = text?.trim().isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasText ? text! : 'Not recorded',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: hasText ? cs.onSurface : cs.outline,
            fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
