import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';
import 'package:hmis/ui/chit/chit_screen.dart';
import 'package:hmis/ui/er_case_register/er_case_register.dart';
import 'package:hmis/ui/home/settings.dart';
import 'package:hmis/ui/marksheet/er_marks.dart';
import 'package:hmis/ui/marksheet/marksheet.dart';
import 'package:hmis/utils/datetime.dart';
import 'package:hmis/utils/of.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final erMarksState = context.of<ErMarksBloc>().state;
    final now = DateTime.now();
    // Query by shift date — patients 00:00–07:59 belong to previous day's shift
    final today = shiftDateOf(now);
    final todayTotal = erMarksState.totalCountForDate(today);
    final todayByType = <CaseType, int>{
      for (final c in CaseType.values)
        c:
            erMarksState.cellCount(
              date: today,
              shift: DutyShift.morning,
              caseType: c,
            ) +
            erMarksState.cellCount(
              date: today,
              shift: DutyShift.evening,
              caseType: c,
            ) +
            erMarksState.cellCount(
              date: today,
              shift: DutyShift.night,
              caseType: c,
            ),
    };
    final byShift = <DutyShift, int>{
      for (final s in DutyShift.values)
        s: erMarksState
            .dailySheet(today)
            .where((m) => m.shift == s.index)
            .length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('HMIS'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.read<SettingsCubit>().onDarkToggled(),
            icon: Icon(
              context.of<SettingsCubit>().state.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: context.of<SettingsCubit>().state.dark
                ? 'Light Mode'
                : 'Dark Mode',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(now).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          
          // ─── PRIMARY ACTIONS ─────────────────────────────────────
          Row(
            children: [
              _ActionCard(
                icon: CupertinoIcons.doc_text_fill,
                label: 'New Chit',
                color: Colors.blue,
                onTap: () => navigateTo(const ChitScreen()),
              ),
              const SizedBox(width: 12),
              _ActionCard(
                icon: CupertinoIcons.table_fill,
                label: 'Marksheet',
                color: Colors.orange,
                onTap: () => navigateTo(const Marksheet()),
              ),
              const SizedBox(width: 12),
              _ActionCard(
                icon: CupertinoIcons.doc_text,
                label: 'Register',
                color: Colors.teal,
                onTap: () => navigateTo(const ErCaseRegister()),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── TODAY TOTAL HERO ────────────────────────────────────
          _HeroCard(total: todayTotal, byShift: byShift),
          const SizedBox(height: 24),

          // ─── TODAY BY CASE TYPE ──────────────────────────────────
          _SectionLabel("Today's Cases by Type"),
          const SizedBox(height: 12),
          _CaseTypeGrid(todayByType: todayByType),
          const SizedBox(height: 24),

          // ─── RECENT PATIENTS ─────────────────────────────────────
          _SectionLabel("Recent Patients Today"),
          const SizedBox(height: 12),
          _RecentPatientsList(shiftDate: today),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── HERO CARD ───────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final int total;
  final Map<DutyShift, int> byShift;

  const _HeroCard({required this.total, required this.byShift});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1C3A5E), const Color(0xFF0D2137)]
              : [CupertinoColors.activeBlue, const Color(0xFF0055C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.activeBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S PATIENTS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xAAFFFFFF),
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('hh:mm a').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$total',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: CupertinoColors.white,
              height: 1,
              letterSpacing: -2,
            ),
          ),
          const Text(
            'Total Cases Recorded',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xBBFFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: DutyShift.values.map((shift) {
              return Expanded(
                child: _ShiftBadge(shift: shift, count: byShift[shift] ?? 0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ShiftBadge extends StatelessWidget {
  final DutyShift shift;
  final int count;

  const _ShiftBadge({required this.shift, required this.count});

  IconData get _icon {
    switch (shift) {
      case DutyShift.morning:
        return CupertinoIcons.sun_max_fill;
      case DutyShift.evening:
        return CupertinoIcons.sunset_fill;
      case DutyShift.night:
        return CupertinoIcons.moon_stars_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(_icon, size: 16, color: CupertinoColors.white.withOpacity(0.8)),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: CupertinoColors.white,
            ),
          ),
          Text(
            shift.label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white.withOpacity(0.65),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CASE TYPE GRID ──────────────────────────────────────────────────────────

class _CaseTypeGrid extends StatelessWidget {
  final Map<CaseType, int> todayByType;

  const _CaseTypeGrid({required this.todayByType});

  @override
  Widget build(BuildContext context) {
    final types = CaseType.values;
    return Column(
      children: [
        for (int i = 0; i < types.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: _CaseTypeTile(
                    type: types[i],
                    count: todayByType[types[i]] ?? 0,
                  ),
                ),
                const SizedBox(width: 10),
                if (i + 1 < types.length)
                  Expanded(
                    child: _CaseTypeTile(
                      type: types[i + 1],
                      count: todayByType[types[i + 1]] ?? 0,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

class _CaseTypeTile extends StatelessWidget {
  final CaseType type;
  final int count;

  const _CaseTypeTile({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'case' : 'cases'}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: count > 0
                        ? color
                        : CupertinoColors.tertiaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RECENT PATIENTS ──────────────────────────────────────────────────────────

class _RecentPatientsList extends StatelessWidget {
  final DateTime shiftDate;

  const _RecentPatientsList({required this.shiftDate});

  @override
  Widget build(BuildContext context) {
    final erMarksState = context.watch<ErMarksBloc>().state;
    final recent =
        erMarksState
            .dailySheet(shiftDate)
            .where((m) => m.patientName.isNotEmpty)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                CupertinoIcons.person_crop_circle,
                size: 40,
                color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              ),
              const SizedBox(height: 8),
              Text(
                'No named patients recorded today',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recent.take(10).map((mark) {
        final caseType = CaseType.values[mark.caseType];
        final shift = DutyShift.values[mark.shift];
        final color = caseType.color;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(caseType.icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mark.patientName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _Tag(label: caseType.label, color: color),
                        const SizedBox(width: 6),
                        _Tag(
                          label: shift.label,
                          color: CupertinoColors.systemGrey,
                        ),
                        if (mark.ageYears > 0) ...[
                          const SizedBox(width: 6),
                          _Tag(
                            label: '${mark.ageYears} yrs',
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('hh:mm a').format(mark.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    );
  }
}
