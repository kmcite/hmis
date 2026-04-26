import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/data/chit_repository.dart';
import 'package:hmis/data/drugs/drugs.dart';
import 'package:hmis/data/drugs/drug_metadata.dart';
import 'package:hmis/data/preparations.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/chit/sections/section_card.dart';
import 'package:hmis/ui/chit/sections/chit_chip.dart';
import 'package:hmis/models/models.dart';

class PrescriptionSection extends StatefulWidget {
  const PrescriptionSection({super.key});

  @override
  State<PrescriptionSection> createState() => _PrescriptionSectionState();
}

class _PrescriptionSectionState extends State<PrescriptionSection> {
  void _openRxBuilder(Drugs drug, {Preparations? initialPrep}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _RxBuilder(drug: drug, initialPrep: initialPrep),
    );
  }

  void _openDrugPicker(Preparations prep) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Select ${prep.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: Drugs.values.map((drug) {
                  return ListTile(
                    visualDensity: VisualDensity.compact,
                    title: Text(drug.brandNames),
                    onTap: () {
                      Navigator.pop(context);
                      _openRxBuilder(drug, initialPrep: prep);
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chit = context.watch<ChitNotifier>().state;
    final prescriptions = chit.prescriptions;

    final suggestedDrugs = ChitRepository.suggestDrugs(chit.diseases);

    return SectionCard(
      title: 'Rx — Prescription',
      children: [
        if (prescriptions.isNotEmpty) ...[
          ...prescriptions.asMap().entries.map((e) {
            final rx = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${rx.prep.name} ${rx.drug.brandNames} ${rx.dose} ${rx.freq.name} (${rx.duration.name})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        context.read<ChitNotifier>().removeRx(e.key),
                    color: colorScheme.outline,
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
          const SizedBox(height: 12),
        ],

        if (suggestedDrugs.isNotEmpty) ...[
          Text(
            'Suggested',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: suggestedDrugs.map((drug) {
              return ChitChip(
                label: drug.brandNames,
                activeColor: Colors.teal,
                onTap: () => _openRxBuilder(drug),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        Text(
          'Select by form',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: Preparations.values.map((prep) {
            return ChitChip(
              label: prep.name,
              onTap: () => _openDrugPicker(prep),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RxBuilder extends StatefulWidget {
  final Drugs drug;
  final Preparations? initialPrep;

  const _RxBuilder({
    required this.drug,
    this.initialPrep,
  });

  @override
  State<_RxBuilder> createState() => _RxBuilderState();
}

class _RxBuilderState extends State<_RxBuilder> {
  late Preparations _prep;
  String _dose = doses.first;
  Frequencies _freq = Frequencies.sos;
  DrugDuration _duration = DrugDuration.threeDays;

  @override
  void initState() {
    super.initState();
    _prep = widget.initialPrep ?? Preparations.tablet;
  }

  Widget _chips<T>(
    String label,
    List<T> options,
    T selected,
    void Function(T) onSelect,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: options.map((o) {
            return ChitChip(
              label: '$o',
              isSelected: selected == o,
              onTap: () => setState(() => onSelect(o)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.drug.brandNames,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.drug.category,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            _chips<Preparations>(
              'Form',
              Preparations.values,
              _prep,
              (v) => _prep = v,
            ),

            _chips<String>(
              'Dose',
              doses,
              _dose,
              (v) => _dose = v,
            ),

            _chips<Frequencies>(
              'Frequency',
              Frequencies.values,
              _freq,
              (v) => _freq = v,
            ),

            _chips<DrugDuration>(
              'Duration',
              DrugDuration.values,
              _duration,
              (v) => _duration = v,
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<ChitNotifier>().addRx(
                    RxEntry(
                      drug: widget.drug,
                      prep: _prep,
                      dose: _dose,
                      freq: _freq,
                      duration: _duration,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add to Prescription'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
