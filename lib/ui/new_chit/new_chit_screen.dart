import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/patient_draft_cubit.dart';
import 'package:hmis/business/new_chit_cubit.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/shared/widgets/sheet_arrival_banner.dart';
class NewChitScreen extends StatelessWidget {
  const NewChitScreen({super.key});

  @override
  Widget build(BuildContext context) => const _NewChitScreenBody();
}

class _NewChitScreenBody extends StatefulWidget {
  const _NewChitScreenBody();

  @override
  State<_NewChitScreenBody> createState() => _NewChitScreenBodyState();
}

class _NewChitScreenBodyState extends State<_NewChitScreenBody> {
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final editing = context.read<PatientDraftCubit>().state.selectedId != null;
      if (!editing) {
        context.read<NewChitCubit>().init();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = context.watch<PatientDraftCubit>().state.selectedId != null;
    final patient = editing
        ? context.watch<PatientDraftCubit>().state.draft
        : context.watch<NewChitCubit>().state.patient;

    return patient == null
        ? const LiquidScaffold(
            body: LiquidProgress(message: 'Preparing form…'),
          )
        : LiquidScaffold(
            appBar: LiquidAppBar(
              title: editing ? 'Edit case' : 'New ER entry',
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  SheetArrivalBanner(patient: patient, liveClock: !editing && !patient.isPersisted),
                  _PatientCard(patient: patient, editing: editing),
                  _ClinicalCard(patient: patient, editing: editing),
                  _CaseTypeGrid(patient: patient, editing: editing),
                ],
              ),
            ),
            bottomNavigationBar: _ActionBar(patient: patient, editing: editing),
          );
  }
}

// ── Patient Info ─────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final bool editing;
  const _PatientCard({required this.patient, required this.editing});

  @override
  Widget build(BuildContext context) {
    final newChit = context.read<NewChitCubit>();
    final draft = context.read<PatientDraftCubit>();
    return LiquidCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const LiquidSectionHeader(
            icon: Icons.person_pin_outlined,
            label: 'Patient',
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                flex: 3,
                child: LiquidTextField(
                  key: ValueKey('name-${patient.id}'),
                  label: 'Name',
                  initialValue: patient.patientName ?? '',
                  onChanged: editing ? draft.editName : newChit.onPatientName,
                ),
              ),
              Expanded(
                child: LiquidTextField(
                  key: ValueKey('age-${patient.id}'),
                  label: 'Age',
                  initialValue: patient.ageYears?.toString() ?? '',
                  onChanged: editing ? draft.editAge : newChit.onAgeInYears,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              const SizedBox(
                width: 44,
                child: Text(
                  'SEX',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Expanded(
                child: _GenderSegment(
                  label: 'M',
                  icon: Icons.male,
                  selected: patient.isMale == true,
                  onTap: () => _setGender(context, patient, true),
                ),
              ),
              Expanded(
                child: _GenderSegment(
                  label: 'F',
                  icon: Icons.female,
                  selected: patient.isMale == false,
                  onTap: () => _setGender(context, patient, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setGender(BuildContext context, Patient patient, bool value) {
    // Tapping the active segment clears the selection (unknown sex).
    final next = patient.isMale == value ? null : value;
    final editing = context.read<PatientDraftCubit>().state.selectedId != null;
    if (editing) {
      context.read<PatientDraftCubit>().editGender(next);
    } else {
      context.read<NewChitCubit>().onIsMale(next);
    }
  }
}

class _GenderSegment extends StatelessWidget {
  const _GenderSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.primary : cs.onSurfaceVariant;
    return LiquidSurface(
      onTap: onTap,
      variant: selected ? LiquidVariant.accent : LiquidVariant.inset,
      tint: cs.primary,
      selected: selected,
      radius: 12,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          Icon(icon, size: 18, color: fg),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Clinical Notes ───────────────────────────────────────────────────────

class _ClinicalCard extends StatelessWidget {
  final Patient patient;
  final bool editing;
  const _ClinicalCard({required this.patient, required this.editing});

  @override
  Widget build(BuildContext context) {
    final newChit = context.read<NewChitCubit>();
    final draft = context.read<PatientDraftCubit>();
    return LiquidCard(
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
          LiquidTextField(
            key: ValueKey('history-${patient.id}'),
            label: 'Hx — history taking',
            hint: 'Chief complaint, history…',
            initialValue: patient.history ?? '',
            onChanged: editing ? draft.editHistory : newChit.onHistory,
            minLines: 3,
            maxLines: 8,
          ),
          LiquidTextField(
            key: ValueKey('exam-${patient.id}'),
            label: 'O/E — on examination',
            hint: 'Findings…',
            initialValue: patient.examination ?? '',
            onChanged: editing ? draft.editExamination : newChit.onExamination,
            minLines: 3,
            maxLines: 8,
          ),
          LiquidTextField(
            key: ValueKey('mgmt-${patient.id}'),
            label: 'Management',
            hint: 'Plan, investigations, referrals…',
            initialValue: patient.management ?? '',
            onChanged: editing ? draft.editManagement : newChit.onManagement,
            minLines: 3,
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}

// ── Case Type ───────────────────────────────────────────────────────────

class _CaseTypeGrid extends StatelessWidget {
  final Patient patient;
  final bool editing;
  const _CaseTypeGrid({required this.patient, required this.editing});

  static const _icons = {
    CaseType.medical: Icons.local_hospital,
    CaseType.surgical: Icons.medical_services,
    CaseType.pediatrics: Icons.child_care,
    CaseType.dogBite: Icons.pets,
    CaseType.mlc: Icons.gavel,
    CaseType.postmortem: Icons.science,
  };

  @override
  Widget build(BuildContext context) {
    final newChit = context.read<NewChitCubit>();
    final draft = context.read<PatientDraftCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        const LiquidFieldLabel('CASE TYPE'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.88,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: CaseType.values.length,
          itemBuilder: (_, i) {
            final ct = CaseType.values[i];
            final selected = ct == patient.caseType;
            return LiquidSelectableTile(
              icon: _icons[ct] ?? Icons.circle,
              label: ct.label,
              selected: selected,
              radius: 14,
              onTap: () =>
                  editing ? draft.editCaseType(ct) : newChit.onCaseType(ct),
            );
          },
        ),
      ],
    );
  }
}

// ── Bottom Action Bar ──────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final Patient patient;
  final bool editing;
  const _ActionBar({required this.patient, required this.editing});

  @override
  Widget build(BuildContext context) {
    final newChit = context.read<NewChitCubit>();
    final draftCubit = context.read<PatientDraftCubit>();
    final draftState = context.watch<PatientDraftCubit>().state;
    final canSave = editing
        ? draftState.canSave
        : (patient.patientName ?? '').trim().isNotEmpty;

    Future<void> save() async {
      if (!canSave) return;
      if (editing) {
        await draftCubit.commit();
        if (context.mounted) {
          showLiquidSnackBar(context, 'Case updated', icon: Icons.check_circle);
          Navigator.of(context).pop();
        }
        return;
      }
      await newChit.save();
      if (context.mounted) {
        showLiquidSnackBar(context, 'Case saved', icon: Icons.check_circle);
        Navigator.of(context).pop();
      }
    }

    return SafeArea(
      child: LiquidSurface(
        variant: LiquidVariant.elevated,
        radius: 0,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          spacing: 10,
          children: [
            LiquidButton(
              onPressed: () => Navigator.of(context).pop(),
              style: LiquidButtonStyle.plain,
              icon: const Icon(Icons.close_rounded),
              child: const Text('Cancel'),
            ),
            Expanded(
              child: LiquidButton(
                onPressed: canSave ? save : null,
                expand: true,
                icon: const Icon(Icons.check_circle_outline),
                child: Text(editing ? 'Save changes' : 'Save entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
