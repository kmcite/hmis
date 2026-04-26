import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/data/findings.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/chit/sections/section_card.dart';
import 'package:hmis/ui/chit/sections/chit_chip.dart';

class ExaminationSection extends StatefulWidget {
  const ExaminationSection({super.key});

  @override
  State<ExaminationSection> createState() => _ExaminationSectionState();
}

class _ExaminationSectionState extends State<ExaminationSection> {
  @override
  Widget build(BuildContext context) {
    final findings = context.watch<ChitNotifier>().state.findings;

    return SectionCard(
      title: 'O/E — Examination',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Findings.values.map((f) {
            final selected = findings.any((e) => e.finding == f);
            return ChitChip(
              label: f.name,
              isSelected: selected,
              onTap: () {
                context.read<ChitNotifier>().toggleFinding(f);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
