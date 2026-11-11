import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/patient/patient_details_screen.dart';
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
                _RecentRow(patient: recent[i]),
                if (i < recent.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.patient});

  final Patient patient;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientDetailsScreen(patientId: patient.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = patient.caseType.color;
    final cs = Theme.of(context).colorScheme;
    final time = patient.createdAt;

    return LiquidListTile(
      onTap: () => _open(context),
      leading: Icon(patient.caseType.icon, size: 22),
      title: Text(patient.patientName!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${patient.caseType.label} · ${patient.shift.label}'
            '${patient.ageYears != null ? ' · ${patient.ageYears} yrs' : ''}',
          ),
          const SizedBox(height: 4),
          PatientDateChips(patient: patient),
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
