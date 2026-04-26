import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/chit/sections/section_card.dart';

class ChitPreview extends StatelessWidget {
  const ChitPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final text = context.watch<ChitNotifier>().state.toText();

    return SectionCard(
      title: 'Preview - Clinical Log',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: text.isEmpty
              ? Text(
                  'Fill in sections below to build the chit.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
