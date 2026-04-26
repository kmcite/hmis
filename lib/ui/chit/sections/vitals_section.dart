import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/models/models.dart';
import 'package:hmis/ui/chit/vital_tile.dart';
import 'section_card.dart';

class VitalsSection extends StatelessWidget {
  const VitalsSection({super.key});

  Color _flagColor(int severity) {
    if (severity >= 3) return Colors.red;
    if (severity == 2) return Colors.orange;
    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ChitNotifier, PatientChit>(
      builder: (context, chit) {
        final vitals = chit.vitals;
        final flags = vitals.flags;
        final double tileWidth =
            (MediaQuery.of(context).size.width - 32 - 16 - 24) / 3;

        // Pre-compute worst flag per vital axis
        Color? bpFlag, pulseFlag, spo2Flag, tempFlag, rrFlag;
        for (final flag in flags) {
          final color = _flagColor(flag.severity);
          switch (flag.vital) {
            case 'BP':
              bpFlag ??= color;
              break;
            case 'Pulse':
              pulseFlag ??= color;
              break;
            case 'SpO2':
              spo2Flag ??= color;
              break;
            case 'Temp':
              tempFlag ??= color;
              break;
            case 'RR':
              rrFlag ??= color;
              break;
          }
        }

        return SectionCard(
          title: 'Vitals — Status',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                VitalTile(
                  label: 'BLOOD PRESSURE',
                  value: '${vitals.systolic}/${vitals.diastolic}',
                  unit: 'mmHg',
                  isBP: true,
                  width: tileWidth * 2 + 8,
                  accentColor: Colors.red[700]!,
                  onDrag: (d) => context.read<ChitNotifier>().updateSystolic(d),
                  onSecondaryDrag: (d) =>
                      context.read<ChitNotifier>().updateDiastolic(d),
                  isAbnormal: bpFlag != null,
                  abnormalColor: bpFlag ?? Colors.orange,
                ),
                VitalTile(
                  label: 'HEART RATE',
                  value: '${vitals.pulse}',
                  unit: 'BPM',
                  width: tileWidth,
                  accentColor: colorScheme.primary,
                  onDrag: (d) => context.read<ChitNotifier>().updatePulse(d),
                  isAbnormal: pulseFlag != null,
                  abnormalColor: pulseFlag ?? Colors.orange,
                ),
                VitalTile(
                  label: 'SPO2',
                  value: '${vitals.spo2}',
                  unit: '%',
                  width: tileWidth,
                  accentColor: Colors.teal,
                  onDrag: (d) => context.read<ChitNotifier>().updateSpO2(d),
                  isAbnormal: spo2Flag != null,
                  abnormalColor: spo2Flag ?? Colors.orange,
                ),
                VitalTile(
                  label: 'TEMP',
                  value: vitals.temp.toStringAsFixed(1),
                  unit: '°F',
                  width: tileWidth,
                  accentColor: Colors.deepOrange,
                  onDrag: (d) =>
                      context.read<ChitNotifier>().updateTemp(d * 0.1),
                  isAbnormal: tempFlag != null,
                  abnormalColor: tempFlag ?? Colors.orange,
                ),
                VitalTile(
                  label: 'RESP RATE',
                  value: '${vitals.rr}',
                  unit: '/min',
                  width: tileWidth,
                  accentColor: Colors.indigo,
                  onDrag: (d) => context.read<ChitNotifier>().updateRR(d),
                  isAbnormal: rrFlag != null,
                  abnormalColor: rrFlag ?? Colors.orange,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
