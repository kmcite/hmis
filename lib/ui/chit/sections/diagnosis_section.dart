import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/data/chit_repository.dart';
import 'package:hmis/data/diagnosis_confidence.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/chit/sections/section_card.dart';
import 'package:hmis/ui/chit/sections/chit_chip.dart';

class DiagnosisSection extends StatefulWidget {
  const DiagnosisSection({super.key});

  @override
  State<DiagnosisSection> createState() => _DiagnosisSectionState();
}

class _DiagnosisSectionState extends State<DiagnosisSection> {
  Color _severityColor(int severity) {
    if (severity >= 3) return Colors.red;
    if (severity == 2) return Colors.orange;
    return Colors.amber;
  }

  IconData _vitalIcon(String vital) {
    switch (vital) {
      case 'Pulse':
        return Icons.favorite;
      case 'RR':
        return Icons.air;
      case 'SpO2':
        return Icons.bloodtype;
      case 'BP':
        return Icons.speed;
      case 'Temp':
        return Icons.thermostat;
      default:
        return Icons.monitor_heart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chit = context.watch<ChitNotifier>().state;
    final vitals = chit.vitals;
    final flags = vitals.flags;
    final suggested = ChitRepository.computeDifferentialFromChit(chit);

    return SectionCard(
      title: 'Dx — Diagnosis',
      children: [
        // ── Vital flags banner ──────────────────────────────
        if (flags.isNotEmpty) ...[
          Text(
            'VITAL SIGNS ABNORMALITIES',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: flags.map((flag) {
              final color = _severityColor(flag.severity);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_vitalIcon(flag.vital), size: 14, color: color),
                    const SizedBox(width: 8),
                    Text(
                      flag.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
        ],

        // ── Differential results ────────────────────────────
        if (suggested.isEmpty)
          Text(
            flags.isEmpty
                ? 'Add complaints, findings, or adjust vitals to get suggestions.'
                : 'Vital flags captured. Add complaints to narrow the differential.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          Text(
            'DIFFERENTIAL DIAGNOSIS',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggested.map((result) {
              final disease = result.disease;
              final selected = context.read<ChitNotifier>().isDiagnosisSelected(disease);
              final confidence = result.score >= 4 ? DiagnosisConfidence.likely : DiagnosisConfidence.unlikely;
              
              return ChitChip(
                label:
                    '${disease.label}  •  ${result.score}  ${confidence.emoji}',
                isSelected: selected,
                activeColor: _confidenceColor(confidence, colorScheme),
                onTap: () =>
                    context.read<ChitNotifier>().toggleDiagnosis(disease),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Color _confidenceColor(DiagnosisConfidence confidence, ColorScheme colorScheme) {
    switch (confidence) {
      case DiagnosisConfidence.likely:
        return colorScheme.primary;
      case DiagnosisConfidence.unlikely:
        return colorScheme.outline;
    }
  }
}
