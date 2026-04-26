import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/data/symptoms.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/chit/sections/section_card.dart';
import 'package:hmis/ui/chit/sections/chit_chip.dart';

class SymptomsSection extends StatefulWidget {
  const SymptomsSection({super.key});

  @override
  State<SymptomsSection> createState() => _SymptomsSectionState();
}

class _SymptomsSectionState extends State<SymptomsSection> {
  void _onSymptomTap(Symptoms symptom) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (_) => _DurationPicker(symptom: symptom),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chit = context.watch<ChitNotifier>().state;
    final selectedSymptoms = chit.symptoms;
    return SectionCard(
      title: 'SYMPTOMS',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Symptoms.values.map((symptom) {
            final isSelected = selectedSymptoms.any(
              (c) => c.symptom == symptom,
            );
            return ChitChip(
              label: isSelected
                  ? "${symptom.name} ${selectedSymptoms.firstWhere((c) => c.symptom == symptom).duration}"
                  : symptom.name,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  final index = selectedSymptoms.indexWhere(
                    (c) => c.symptom == symptom,
                  );
                  context.read<ChitNotifier>().removeComplaint(index);
                } else {
                  _onSymptomTap(symptom);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final Symptoms symptom;
  const _DurationPicker({required this.symptom});

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ChitNotifier>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.access_time, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Duration: ${symptom.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ...symptom.typicalDurations.map((d) {
            return ListTile(
              title: Text(d),
              onTap: () {
                notifier.addComplaint(symptom, d);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
