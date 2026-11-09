import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/er_mark_draft_cubit.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';
import 'package:hmis/ui/shared/widgets/sheet_arrival_banner.dart';
import 'package:intl/intl.dart';

/// Latest named entries today (up to 10) — operational “activity feed”.
class HomeRecentPatients extends StatelessWidget {
  const HomeRecentPatients({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    final recent = home.recentNamed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: LiquidSectionLabel(
                'Recent patients',
                padding: EdgeInsets.zero,
              ),
            ),
            if (!home.todayLoading)
              Text(
                '${recent.length} shown',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (home.todayLoading)
          const LiquidProgress(message: 'Loading activity…')
        else if (recent.isEmpty)
          LiquidCard(
            specular: false,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Icon(
                  Icons.person_search_outlined,
                  size: 36,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'No named patients yet today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < recent.length; i++) ...[
                _RecentRow(mark: recent[i]),
                if (i < recent.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.mark});

  final Mark mark;

  void _open(BuildContext context) {
    context.read<ErMarkDraftCubit>().open(mark.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewChitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = mark.caseType.color;
    final cs = Theme.of(context).colorScheme;
    final time = mark.createdAt;

    return LiquidListTile(
      onTap: () => _open(context),
      leading: Icon(mark.caseType.icon, size: 22),
      title: Text(mark.patientName!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${mark.caseType.label} · ${mark.shift.label}'
            '${mark.ageYears != null ? ' · ${mark.ageYears} yrs' : ''}',
          ),
          const SizedBox(height: 4),
          MarkDateChips(mark: mark),
        ],
      ),
      trailing: time == null
          ? null
          : Text(
              DateFormat('HH:mm').format(time),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
      tint: color,
      variant: LiquidVariant.surface,
    );
  }
}
