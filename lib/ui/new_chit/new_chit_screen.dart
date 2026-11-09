import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/er_mark_draft_cubit.dart';
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
      final editing = context.read<ErMarkDraftCubit>().state.selectedId != null;
      if (!editing) {
        context.read<NewChitCubit>().init();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = context.watch<ErMarkDraftCubit>().state.selectedId != null;
    final mark = editing
        ? context.watch<ErMarkDraftCubit>().state.draft
        : context.watch<NewChitCubit>().state.mark;

    return mark == null
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
                  SheetArrivalBanner(mark: mark, liveClock: !editing && !mark.isPersisted),
                  _PatientCard(erMark: mark, editing: editing),
                  _CaseTypeGrid(erMark: mark, editing: editing),
                ],
              ),
            ),
            bottomNavigationBar: _ActionBar(erMark: mark, editing: editing),
          );
  }
}

// ── Patient Info ─────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final Mark erMark;
  final bool editing;
  const _PatientCard({required this.erMark, required this.editing});

  @override
  Widget build(BuildContext context) {
    final newChit = context.read<NewChitCubit>();
    final draft = context.read<ErMarkDraftCubit>();
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
                  key: ValueKey('name-${erMark.id}'),
                  label: 'Name',
                  initialValue: erMark.patientName ?? '',
                  onChanged: editing ? draft.editName : newChit.onPatientName,
                ),
              ),
              Expanded(
                child: LiquidTextField(
                  key: ValueKey('age-${erMark.id}'),
                  label: 'Age',
                  initialValue: erMark.ageYears?.toString() ?? '',
                  onChanged: editing ? draft.editAge : newChit.onAgeInYears,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          LiquidTextField(
            key: ValueKey('remarks-${erMark.id}'),
            label: 'Clinical notes',
            hint: 'Presentation, plan, handover…',
            initialValue: erMark.remarks ?? '',
            onChanged: editing ? draft.editRemarks : newChit.onRemarks,
            minLines: 5,
            maxLines: 12,
          ),
        ],
      ),
    );
  }
}

// ── Case Type ───────────────────────────────────────────────────────────

class _CaseTypeGrid extends StatelessWidget {
  final Mark erMark;
  final bool editing;
  const _CaseTypeGrid({required this.erMark, required this.editing});

  static const _icons = {
    CaseType.medical: Icons.local_hospital,
    CaseType.surgical: Icons.medical_services,
    CaseType.pediatrics: Icons.child_care,
    CaseType.minorOt: Icons.healing,
    CaseType.rta: Icons.directions_car,
    CaseType.dogBite: Icons.pets,
    CaseType.mlc: Icons.gavel,
    CaseType.postmortem: Icons.science,
  };

  @override
  Widget build(BuildContext context) {
    final newChit = context.read<NewChitCubit>();
    final draft = context.read<ErMarkDraftCubit>();
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
            final selected = ct == erMark.caseType;
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
  final Mark erMark;
  final bool editing;
  const _ActionBar({required this.erMark, required this.editing});

  @override
  Widget build(BuildContext context) {
    final newChit = context.read<NewChitCubit>();
    final draftCubit = context.read<ErMarkDraftCubit>();
    final draftState = context.watch<ErMarkDraftCubit>().state;
    final canSave = editing
        ? draftState.canSave
        : (erMark.patientName ?? '').trim().isNotEmpty;

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
        specular: false,
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
