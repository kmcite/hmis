import 'package:flutter/material.dart';
import 'package:hmis/controllers/home.dart';
import 'package:hmis/controllers/sheet.dart';
import 'package:hmis/models/er_mark.dart';
import 'package:hmis/utils/router.dart';
import 'package:intl/intl.dart';

const double _dateBarItemWidth = 64.0;
const double _dateBarItemSpacing = 12.0;
const double _dateBarItemExtent = _dateBarItemWidth + _dateBarItemSpacing;
const double _dateBarPadding = 16.0;
const int _windowDaysHalf = 90; // 90 days before & after = 181 day window

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Mutable per-element state: keeps the date window's anchor stable across
/// rebuilds so selecting a nearby day doesn't reshuffle the whole strip,
/// and owns the [ScrollController] used to keep the selection centered.
class _DateBarState {
  _DateBarState(this.anchor);

  DateTime anchor;
  DateTime? lastCentered;
  final controller = ScrollController();
}

class DateBar extends SignalConsumer {
  const DateBar({super.key});

  @override
  Widget build(BuildContext context) {
    final sheet = sheetController(context);
    final currentSelected = sheet.selectedDay();
    final state = local(
      context,
      #dateBarState,
      () => _DateBarState(_dayOnly(DateTime.now())),
    );

    var offset = currentSelected.difference(state.anchor).inDays;
    if (offset.abs() > _windowDaysHalf) {
      // Selection drifted outside the window (e.g. a big jump) — recenter
      // the anchor so the strip doesn't have to grow unboundedly.
      state.anchor = currentSelected;
      offset = 0;
    }
    final selectedIndex = _windowDaysHalf + offset;

    if (state.lastCentered != currentSelected) {
      state.lastCentered = currentSelected;
      final animate = state.controller.hasClients;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerIndex(state.controller, selectedIndex, animate: animate);
      });
    }

    return Container(
      height: 136,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _MonthHeader(),
          Expanded(
            child: ListView.builder(
              controller: state.controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: _dateBarPadding),
              itemExtent: _dateBarItemExtent,
              itemCount: (_windowDaysHalf * 2) + 1,
              itemBuilder: (context, index) {
                final dayOffset = index - _windowDaysHalf;
                final date = state.anchor.add(Duration(days: dayOffset));
                return _DateTile(date: date);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static void _centerIndex(
    ScrollController controller,
    int index, {
    required bool animate,
  }) {
    if (!controller.hasClients) return;
    final position = controller.position;
    final itemStart = _dateBarPadding + index * _dateBarItemExtent;
    final itemCenter = itemStart + _dateBarItemExtent / 2;
    final target = (itemCenter - position.viewportDimension / 2).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (animate) {
      controller.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      controller.jumpTo(target);
    }
  }
}

class _MonthHeader extends SignalConsumer {
  const _MonthHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sheet = sheetController(context);
    final currentSelected = sheet.selectedDay();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(currentSelected),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: .4,
              ),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: sheet.showToday,
            icon: const Icon(Icons.today_rounded, size: 16),
            label: const Text('Today'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends SignalConsumer {
  const _DateTile({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sheet = sheetController(context);
    final today = homeController(context).todayKey();

    final key = Mark.ymd(date);
    final selected = key == sheet.dayKey();
    final isToday = key == today;

    final background = selected
        ? colors.primary
        : isToday
        ? colors.primaryContainer
        : colors.surfaceContainerHighest.withValues(alpha: 0.6);

    final foreground = selected ? colors.onPrimary : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: _dateBarItemSpacing),
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => sheet.showDay(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: _dateBarItemWidth,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(20),
                border: isToday && !selected
                    ? Border.all(color: colors.primary, width: 1.5)
                    : null,
                boxShadow: [
                  if (selected)
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isToday ? 1.0 : 0.0,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selected ? colors.onPrimary : colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
