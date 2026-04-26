import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';
import 'package:hmis/ui/er_case_register/delete_er_mark.dart';
import 'package:hmis/ui/er_case_register/er_mark.dart';
import 'package:hmis/ui/home/settings.dart';
import 'package:hmis/ui/marksheet/datebar.dart';
import 'package:hmis/ui/marksheet/er_marks.dart';
import 'package:hmis/utils/datetime.dart';
import 'package:intl/intl.dart';

import 'er_case_register_filter.dart';

class ErCaseRegister extends StatelessWidget {
  const ErCaseRegister({super.key});

  Widget _toggleButton(BuildContext context) {
    final filter = context.watch<ErCaseRegisterFilterCubit>().state;
    return IconButton(
      onPressed: () => context.read<ErCaseRegisterFilterCubit>().changeFilter(
        filter == CaseRegisterFilter.casesByDay
            ? CaseRegisterFilter.allCases
            : CaseRegisterFilter.casesByDay,
      ),
      icon: Icon(
        filter == CaseRegisterFilter.casesByDay
            ? Icons.list
            : Icons.calendar_month,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<ErCaseRegisterFilterCubit>().state;
    final currentDate = context
        .watch<SettingsCubit>()
        .state
        .currentlySelectedDate;
    final erMarksState = context.watch<ErMarksBloc>().state;

    final title = filter == CaseRegisterFilter.casesByDay
        ? 'Shift — ${DateFormat('d MMM').format(currentDate)}'
        : 'All Cases (${erMarksState.all.length})';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [_toggleButton(context)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (filter == CaseRegisterFilter.casesByDay) const DateBar(),
            Expanded(
              child: filter == CaseRegisterFilter.casesByDay
                  ? _DayView()
                  : _AllCasesView(),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── DAY VIEW (single shift date) ────────────────────────────────────────────

class _DayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentDate = context
        .watch<SettingsCubit>()
        .state
        .currentlySelectedDate;
    final marks = context.watch<ErMarksBloc>().state.casesByDay(currentDate)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (marks.isEmpty) return _EmptyState();
    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: const EdgeInsets.all(16),
      itemCount: marks.length,
      itemBuilder: (context, index) => _ErMarkTile(marks[index]),
    );
  }
}

// ─── ALL CASES VIEW (grouped by shift date) ───────────────────────────────────

class _AllCasesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = context.watch<ErMarksBloc>().state.allGroupedByShiftDate;

    if (grouped.isEmpty) return _EmptyState();

    final shiftDates = grouped.keys.toList(); // already sorted newest-first

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: shiftDates.length,
      itemBuilder: (context, sectionIndex) {
        final shiftDate = shiftDates[sectionIndex];
        final marks = grouped[shiftDate]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Shift date section header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _shiftDateLabel(shiftDate),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${marks.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Tiles for this shift date ──
            ...marks.map(
              (mark) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ErMarkTile(mark),
              ),
            ),
          ],
        );
      },
    );
  }

  String _shiftDateLabel(DateTime shiftDate) {
    final now = shiftDateOf(DateTime.now());
    final yesterday = shiftDateOf(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    if (_isSameDay(shiftDate, now))
      return 'Today · ${DateFormat('d MMM yyyy').format(shiftDate)}';
    if (_isSameDay(shiftDate, yesterday))
      return 'Yesterday · ${DateFormat('d MMM yyyy').format(shiftDate)}';
    return 'Shift ${DateFormat('d MMM yyyy').format(shiftDate)}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: theme.disabledColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cases recorded',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Cases saved from the chit or marksheet appear here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ER MARK TILE ─────────────────────────────────────────────────────────────

class _ErMarkTile extends StatelessWidget {
  final ErMark mark;
  const _ErMarkTile(this.mark);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shift = DutyShift.values[mark.shift];
    final caseType = CaseType.values[mark.caseType];
    final color = caseType.color;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => navigateToDialog(ErMarkPage(mark)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(caseType.icon, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          caseType.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shift.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => navigateToDialog(ErMarkPage(mark)),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => navigateToDialog(DeleteErMarkDialog(mark)),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Patient info
              Text(
                mark.patientName.isEmpty
                    ? 'Anonymous Patient'
                    : mark.patientName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mark.patientName.isEmpty
                      ? theme.disabledColor
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              // Meta row — real wall-clock createdAt + age
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    // Real datetime (wall-clock, never altered)
                    mark.createdAt.formattedDateTime(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  if (mark.ageYears > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mark.info,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
              if (mark.remarks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  mark.remarks,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
