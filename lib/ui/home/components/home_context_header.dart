import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:intl/intl.dart';

/// Live wall clock + operational sheet day (08:00 rollover).
class HomeContextHeader extends StatefulWidget {
  const HomeContextHeader({super.key});

  @override
  State<HomeContextHeader> createState() => _HomeContextHeaderState();
}

class _HomeContextHeaderState extends State<HomeContextHeader> {
  late DateTime _now;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sheet = HospitalTime.sheetDateFor(_now);
    final rollover = HospitalTime.sheetDiffersFromArrival(
      sheetDate: sheet,
      arrival: _now,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('HH:mm:ss').format(_now),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE · d MMMM yyyy').format(_now),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        LiquidSurface(
          variant: LiquidVariant.inset,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.event_note_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rollover
                      ? 'Sheet day: ${DateFormat('EEE d MMM').format(sheet)} '
                          '(night hours still count here)'
                      : 'Sheet day: ${DateFormat('EEE d MMM').format(sheet)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
