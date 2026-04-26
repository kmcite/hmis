import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';
import 'package:hmis/ui/marksheet/er_mark_to_create.dart';
import 'package:hmis/utils/datetime.dart';

class AddMarkDialog extends StatefulWidget {
  const AddMarkDialog({super.key});

  @override
  State<AddMarkDialog> createState() => _AddMarkDialogState();
}

class _AddMarkDialogState extends State<AddMarkDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.read<ErMarkToCreateCubit>().create();
    });
  }

  @override
  void dispose() {
    // Cannot access context in dispose reliably for cubit if provided above, but we can do it if we capture it
    // Or just clear it right away
    super.dispose();
  }

  @override
  Widget build(context) {
    final erMark = context.watch<ErMarkToCreateCubit>().state;
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      child: erMark == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : Scaffold(
              backgroundColor: cs.surfaceContainerLow,
              appBar: AppBar(
                backgroundColor: cs.surfaceContainerLow,
                elevation: 0,
                title: const Text('New ER Entry'),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    _PatientCard(erMark: erMark),
                    _ShiftSelector(erMark: erMark),
                    _CaseTypeGrid(erMark: erMark),
                  ],
                ),
              ),
              bottomNavigationBar: _ActionBar(erMark: erMark),
            ),
    );
  }
}

// ── Patient Info ─────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final ErMark erMark;
  const _PatientCard({required this.erMark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              children: [
                Icon(Icons.person_pin_outlined, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'Patient',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  flex: 3,
                  child: _FilledField(
                    label: 'Name',
                    initialValue: erMark.patientName,
                    onChanged: context
                        .read<ErMarkToCreateCubit>()
                        .changePatientName,
                  ),
                ),
                Expanded(
                  child: _FilledField(
                    label: 'Age',
                    initialValue: erMark.ageYears == 0
                        ? ''
                        : erMark.ageYears.toString(),
                    onChanged: context
                        .read<ErMarkToCreateCubit>()
                        .changeAgeYears,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            _FilledField(
              label: 'Notes (optional)',
              initialValue: erMark.remarks,
              onChanged: context.read<ErMarkToCreateCubit>().changeRemarks,
              minLines: 2,
              maxLines: 4,
              alignLabelWithHint: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final int minLines;
  final int maxLines;
  final bool alignLabelWithHint;

  const _FilledField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.minLines = 1,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        alignLabelWithHint: alignLabelWithHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textAlign: textAlign,
      minLines: minLines,
      maxLines: maxLines,
    );
  }
}

// ── Shift ─────────────────────────────────────────────────────────────────────

class _ShiftSelector extends StatelessWidget {
  final ErMark erMark;
  const _ShiftSelector({required this.erMark});

  static const _shifts = [
    (DutyShift.morning, Icons.wb_sunny, 'Morning'),
    (DutyShift.evening, Icons.wb_twilight, 'Evening'),
    (DutyShift.night, Icons.nights_stay, 'Night'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        _Label('SHIFT'),
        Row(
          spacing: 8,
          children: _shifts.map((s) {
            final (shift, icon, label) = s;
            final selected = shift.index == erMark.shift;
            return Expanded(
              child: _ShiftTile(
                icon: icon,
                label: label,
                selected: selected,
                onTap: () =>
                    context.read<ErMarkToCreateCubit>().changeShift(shift),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ShiftTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ShiftTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Case Type ────────────────────────────────────────────────────────────────

class _CaseTypeGrid extends StatelessWidget {
  final ErMark erMark;
  const _CaseTypeGrid({required this.erMark});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        _Label('CASE TYPE'),
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
            final selected = ct.index == erMark.caseType;
            return _CaseTypeTile(
              icon: _icons[ct] ?? Icons.circle,
              label: ct.label,
              selected: selected,
              onTap: () =>
                  context.read<ErMarkToCreateCubit>().changeCaseType(ct),
            );
          },
        ),
      ],
    );
  }
}

class _CaseTypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CaseTypeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom Action Bar ─────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final ErMark erMark;
  const _ActionBar({required this.erMark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
        ),
        child: Row(
          spacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => navigateBack(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (erMark.date.year == 0) {
                    // Store the shift date (not raw calendar date)
                    context.read<ErMarkToCreateCubit>().changeDate(
                      shiftDateOf(DateTime.now()),
                    );
                  }
                  context.read<ErMarkToCreateCubit>().save();
                  navigateBack();
                  context.read<ErMarkToCreateCubit>().clear();
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'Save Entry',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
        letterSpacing: 1.4,
      ),
    );
  }
}
