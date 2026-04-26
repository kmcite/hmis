import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/data/actions.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/chit/sections/section_card.dart';
import 'package:hmis/ui/chit/sections/chit_chip.dart';

class ActionsSection extends StatefulWidget {
  const ActionsSection({super.key});

  @override
  State<ActionsSection> createState() => _ActionsSectionState();
}

class _ActionsSectionState extends State<ActionsSection> {
  @override
  Widget build(BuildContext context) {
    final actions = context.watch<ChitNotifier>().state.actions;

    return SectionCard(
      title: 'Advice',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AllActions.values.map((a) {
            return ChitChip(
              label: a.name,
              isSelected: actions.contains(a),
              onTap: () => context.read<ChitNotifier>().toggleAction(a),
            );
          }).toList(),
        ),
      ],
    );
  }
}
