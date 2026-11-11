import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/home/components/home_shift_utils.dart';

/// Primary KPI block: total cases today + shift distribution (handoff-oriented).
class HomeTodayDashboard extends StatelessWidget {
  const HomeTodayDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    final cs = Theme.of(context).colorScheme;
    final byShift = home.todayByShift;
    final total = home.todayTotal;
    final active = homeActiveShift(home.clock);

    return LiquidSurface(
      variant: LiquidVariant.elevated,
      radius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S CASES",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: home.todayLoading
                          ? Text(
                              '—',
                              key: const ValueKey('load'),
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                color: cs.outline,
                              ),
                            )
                          : Text(
                              '$total',
                              key: ValueKey(total),
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                letterSpacing: -2,
                                color: cs.onSurface,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      total == 1 ? 'case on today\'s sheet' : 'cases on today\'s sheet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              LiquidChip(
                label: active.label,
                icon: active.icon,
                tint: cs.primary,
                dense: true,
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 18),
            _ShiftDistributionBar(byShift: byShift, total: total),
          ],
          const SizedBox(height: 16),
          Row(
            spacing: 8,
            children: [
              for (final shift in DutyShift.values)
                Expanded(
                  child: _ShiftMetric(
                    shift: shift,
                    count: byShift[shift] ?? 0,
                    loading: home.todayLoading,
                    active: shift == active,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiftDistributionBar extends StatelessWidget {
  const _ShiftDistributionBar({
    required this.byShift,
    required this.total,
  });

  final Map<DutyShift, int> byShift;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = [
      cs.primary,
      cs.tertiary,
      cs.secondary,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            for (var i = 0; i < DutyShift.values.length; i++)
              Expanded(
                flex: (byShift[DutyShift.values[i]] ?? 0).clamp(0, total) == 0
                    ? 1
                    : byShift[DutyShift.values[i]]!,
                child: ColoredBox(color: colors[i].withValues(alpha: 0.85)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShiftMetric extends StatelessWidget {
  const _ShiftMetric({
    required this.shift,
    required this.count,
    required this.loading,
    required this.active,
  });

  final DutyShift shift;
  final int count;
  final bool loading;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = active ? cs.primary : cs.onSurfaceVariant;

    return LiquidSurface(
      variant: active ? LiquidVariant.accent : LiquidVariant.inset,
      tint: cs.primary,
      selected: active,
      radius: 14,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Column(
        children: [
          Icon(shift.icon, size: 18, color: tint),
          const SizedBox(height: 4),
          Text(
            loading ? '—' : '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          Text(
            shift.label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: tint,
            ),
          ),
        ],
      ),
    );
  }
}
