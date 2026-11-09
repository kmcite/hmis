import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/new_chit_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/case_register/case_register_screen.dart';
import 'package:hmis/ui/marksheet/marksheet_screen.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';

/// Task-oriented triad: record → sheet → register (frequency-ordered for ER flow).
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      spacing: 10,
      children: [
        Expanded(
          flex: 11,
          child: _ActionTile(
            icon: CupertinoIcons.plus_square_fill,
            label: 'New chit',
            subtitle: 'Record case',
            variant: LiquidVariant.hero,
            tint: cs.primary,
            onTap: () {
              context.read<NewChitCubit>().init();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewChitScreen()),
              );
            },
          ),
        ),
        Expanded(
          flex: 10,
          child: _ActionTile(
            icon: CupertinoIcons.table_fill,
            label: 'Marksheet',
            subtitle: 'Daily grid',
            variant: LiquidVariant.accent,
            tint: cs.tertiary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MarksheetScreen()),
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: _ActionTile(
            icon: CupertinoIcons.tray_full_fill,
            label: 'Register',
            subtitle: 'All cases',
            variant: LiquidVariant.accent,
            tint: cs.secondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CaseRegisterScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.variant,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final LiquidVariant variant;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onHero = variant == LiquidVariant.hero;
    final fg = onHero
        ? Theme.of(context).colorScheme.onPrimary
        : tint;

    return LiquidSurface(
      onTap: onTap,
      variant: variant,
      tint: tint,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      semanticLabel: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: fg),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: fg,
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: onHero
                  ? fg.withValues(alpha: 0.75)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
