import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/patient_draft_cubit.dart';
import 'package:hmis/business/sheet_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/patients_repository.dart';
import 'package:hmis/ui/shared/widgets/hmis_empty_state.dart';

class MarksheetGridDetailsDialog extends StatefulWidget {
  const MarksheetGridDetailsDialog({
    super.key,
    required this.date,
    required this.caseType,
    required this.dutyShift,
  });

  final DateTime date;
  final CaseType caseType;
  final DutyShift dutyShift;

  @override
  State<MarksheetGridDetailsDialog> createState() =>
      _MarksheetGridDetailsDialogState();
}

class _MarksheetGridDetailsDialogState
    extends State<MarksheetGridDetailsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SheetCubit>().selectCell(
        (shift: widget.dutyShift, caseType: widget.caseType),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<SheetCubit>().state.cellPatients;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: LiquidSurface(
          variant: LiquidVariant.elevated,
          radius: LiquidTokens.radiusXl,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            children: [
              LiquidCloseHeader(
                title: '${widget.caseType.label} · ${widget.dutyShift.label}',
              ),
              const SizedBox(height: 8),
              Expanded(
                child: patients.isEmpty
                    ? HmisEmptyState(
                        icon: Icons.medical_services_outlined,
                        title: 'No cases recorded',
                        subtitle: 'Tap counts on the sheet to add cases.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: patients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _PatientCard(patient: patients[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  const _PatientCard({required this.patient});

  Future<void> _delete(BuildContext context) async {
    final repo = context.read<PatientsRepository>();
    final draft = context.read<PatientDraftCubit>();
    await repo.remove(patient.id);
    if (draft.state.selectedId == patient.id) {
      draft.clearSelection();
    }
    if (context.mounted) {
      showLiquidSnackBar(context, 'Case removed', icon: Icons.delete_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidListTile(
      variant: LiquidVariant.surface,
      onTap: () => _delete(context),
      title: Text(
        patient.patientName?.isNotEmpty == true
            ? patient.patientName!
            : 'Anonymous #${patient.id}',
      ),
      subtitle: Text(
        [
          if ((patient.ageYears ?? 0) > 0) '${patient.ageYears} yrs',
          if (patient.remarks?.isNotEmpty == true) patient.remarks!,
          'Tap to delete',
        ].join(' · '),
      ),
      leading: Icon(patient.caseType.icon, size: 22),
      trailing: Icon(Icons.delete_outline, color: cs.error, size: 20),
    );
  }
}
