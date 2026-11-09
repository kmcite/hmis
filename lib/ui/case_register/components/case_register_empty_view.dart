import 'package:flutter/material.dart';
import 'package:hmis/ui/shared/widgets/hmis_empty_state.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) => const HmisEmptyState(
        icon: Icons.inbox_outlined,
        title: 'No cases recorded',
        subtitle: 'Cases saved from a chit or the marksheet appear here',
      );
}
