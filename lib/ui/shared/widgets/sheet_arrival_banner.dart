import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:intl/intl.dart';

/// Sheet day, arrival, and auto-derived shift (not editable).
class SheetArrivalBanner extends StatefulWidget {
  const SheetArrivalBanner({
    super.key,
    required this.patient,
    this.compact = false,
    this.liveClock = false,
  });

  final Patient patient;
  final bool compact;
  /// Updates arrival/shift preview while composing a new chit.
  final bool liveClock;

  @override
  State<SheetArrivalBanner> createState() => _SheetArrivalBannerState();
}

class _SheetArrivalBannerState extends State<SheetArrivalBanner> {
  Timer? _ticker;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    if (widget.liveClock) {
      _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final arrival = widget.liveClock ? _now : widget.patient.effectiveArrival();
    final sheet = HospitalTime.sheetDateFor(arrival);
    final shift = HospitalTime.shiftFor(arrival);
    final distinct = HospitalTime.sheetDiffersFromArrival(
      sheetDate: sheet,
      arrival: arrival,
    );

    return LiquidCard(
      padding: EdgeInsets.all(widget.compact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sheet & shift (automatic)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoLine(
            label: 'Sheet day',
            value: DateFormat('EEE d MMM yyyy').format(sheet),
            hint: 'Duty sheet rolls at 08:00',
            emphasized: true,
          ),
          const SizedBox(height: 8),
          _InfoLine(
            label: widget.liveClock ? 'Arrival (on save)' : 'Arrival',
            value: DateFormat('EEE d MMM · HH:mm').format(arrival),
            hint: distinct
                ? 'Calendar date differs from sheet — both stored'
                : 'Same calendar day as sheet',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              LiquidChip(
                label: shift.label,
                icon: shift.icon,
                tint: cs.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_shiftWindow(shift)} · from clock',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          if (distinct) ...[
            const SizedBox(height: 10),
            LiquidSurface(
              variant: LiquidVariant.accent,
              tint: cs.tertiary,
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.nightlight_round, size: 18, color: cs.tertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Night cases after midnight stay on the previous sheet until 08:00.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _shiftWindow(DutyShift shift) => switch (shift) {
        DutyShift.morning => '08:00–14:00',
        DutyShift.evening => '14:00–20:00',
        DutyShift.night => '20:00–08:00',
      };
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    required this.hint,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final String hint;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 16 : 14,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        Text(
          hint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.outline,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

/// Inline chips for register / recent rows.
class PatientDateChips extends StatelessWidget {
  const PatientDateChips({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    if (!patient.hasDistinctArrivalDay || patient.arrivalAt == null) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        LiquidChip(
          label: 'Sheet ${DateFormat('d/M').format(patient.sheetDate)}',
          dense: true,
          tint: cs.primary,
        ),
        LiquidChip(
          label: 'Arrived ${DateFormat('d/M HH:mm').format(patient.arrivalAt!)}',
          dense: true,
          tint: cs.tertiary,
        ),
      ],
    );
  }
}
