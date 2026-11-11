import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/business/patient_draft_cubit.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/shared/widgets/sheet_arrival_banner.dart';
import 'package:intl/intl.dart';

/// Completion queue: patients quick-added from the marksheet still missing
/// details (name etc.). Hidden when empty. Oldest first.
class HomePendingDetails extends StatelessWidget {
  const HomePendingDetails({super.key});

  static const _previewCount = 5;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    final pending = home.pendingDetails;
    if (pending.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final shown = pending.take(_previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: LiquidSectionLabel(
                'Needs details',
                padding: EdgeInsets.zero,
              ),
            ),
            LiquidChip(
              label: '${pending.length}',
              icon: Icons.edit_note,
              tint: cs.tertiary,
              dense: true,
            ),
          ],
        ),
        const SizedBox(height: 10),
        LiquidBanner(
          tint: cs.tertiary,
          icon: Icons.person_search_outlined,
          message: pending.length == 1
              ? '1 patient added from the marksheet has no details yet'
              : '${pending.length} patients added from the marksheet have no details yet',
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < shown.length; i++) ...[
          _PendingRow(patient: shown[i]),
          if (i < shown.length - 1) const SizedBox(height: 8),
        ],
        if (pending.length > shown.length) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              '+${pending.length - shown.length} more in the register',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.patient});

  final Patient patient;

  void _open(BuildContext context) {
    context.read<PatientDraftCubit>().open(patient.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewChitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = patient.createdAt;

    return LiquidListTile(
      onTap: () => _open(context),
      leading: Icon(Icons.person_outline, size: 22, color: cs.tertiary),
      title: Text(
        'Anonymous patient',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${patient.caseType.label} · ${patient.shift.label}'),
          const SizedBox(height: 4),
          PatientDateChips(patient: patient),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (time != null)
            Text(
              DateFormat('d/M HH:mm').format(time),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: cs.outline),
        ],
      ),
      tint: cs.tertiary,
      variant: LiquidVariant.surface,
    );
  }
}
