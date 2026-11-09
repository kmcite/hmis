import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/domain/models/models.dart';

/// Case mix ranked by volume — bars show share of the busiest category (Pareto-friendly).
class HomeCaseTypeBreakdown extends StatelessWidget {
  const HomeCaseTypeBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    final byType = home.todayByType;
    final total = home.todayTotal;

    final types = CaseType.values.toList()
      ..sort((a, b) => (byType[b] ?? 0).compareTo(byType[a] ?? 0));

    final peak = types
        .map((t) => byType[t] ?? 0)
        .fold<int>(0, (m, v) => v > m ? v : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LiquidSectionLabel('Case mix today'),
        const SizedBox(height: 10),
        if (home.todayLoading)
          const LiquidProgress(compact: true)
        else if (total == 0)
          LiquidCard(
            specular: false,
            padding: const EdgeInsets.all(20),
            child: Text(
              'No cases yet. Start with New chit or tap the marksheet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          LiquidSurface(
            variant: LiquidVariant.surface,
            specular: false,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              children: [
                for (var i = 0; i < types.length; i++) ...[
                  _TypeRow(
                    type: types[i],
                    count: byType[types[i]] ?? 0,
                    barFactor: peak == 0
                        ? 0
                        : (byType[types[i]] ?? 0) / peak,
                    total: total,
                  ),
                  if (i < types.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.type,
    required this.count,
    required this.barFactor,
    required this.total,
  });

  final CaseType type;
  final int count;
  final double barFactor;
  final int total;

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final cs = Theme.of(context).colorScheme;
    final pct = total == 0 ? 0.0 : (count / total) * 100;

    return Row(
      children: [
        LiquidSurface(
          variant: LiquidVariant.accent,
          tint: color,
          specular: false,
          radius: 10,
          padding: const EdgeInsets.all(8),
          child: Icon(type.icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: count > 0 ? cs.onSurface : cs.outline,
                      ),
                    ),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: count > 0 ? color : cs.outline,
                    ),
                  ),
                  if (count > 0 && total > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 5,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: barFactor.clamp(0.0, 1.0),
                      child: ColoredBox(color: color.withValues(alpha: 0.75)),
                    ),
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
