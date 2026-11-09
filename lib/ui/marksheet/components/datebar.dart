import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/business/sheet_cubit.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:intl/intl.dart';

const double _dateBarItemWidth = 58.0;
const double _dateBarItemSpacing = 8.0;
const double _dateBarItemExtent = _dateBarItemWidth + _dateBarItemSpacing;
const double _dateBarPadding = 12.0;
const int _windowDaysHalf = 90;

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class DateBar extends StatefulWidget {
  const DateBar({super.key});

  @override
  State<DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<DateBar> {
  late DateTime _anchor;
  String? _lastCenteredKey;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    final day = context.read<SheetCubit>().state.selectedDay;
    _anchor = _dayOnly(day);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensureAnchor(DateTime selected) {
    final day = _dayOnly(selected);
    final offset = day.difference(_anchor).inDays;
    if (offset.abs() <= _windowDaysHalf) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _anchor = day);
    });
  }

  void _centerOnSelected(String selectedKey, DateTime selectedDay) {
    if (_lastCenteredKey == selectedKey) return;
    _lastCenteredKey = selectedKey;

    final offset = _dayOnly(selectedDay).difference(_anchor).inDays;
    final index = _windowDaysHalf + offset;
    final animate = _controller.hasClients;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerIndex(index, animate: animate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = context.select(
      (SheetCubit c) => c.state.selectedDay,
    );
    final selectedKey = context.select(
      (SheetCubit c) => c.state.dayKey,
    );
    final todayKey = context.select(
      (HomeCubit c) => c.state.todayKey,
    );

    _ensureAnchor(selectedDay);
    _centerOnSelected(selectedKey, selectedDay);

    return LiquidSurface(
      variant: LiquidVariant.elevated,
      radius: 20,
      specular: false,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MonthHeader(selectedDay: selectedDay),
          SizedBox(
            height: 88,
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                _dateBarPadding,
                4,
                _dateBarPadding,
                10,
              ),
              itemExtent: _dateBarItemExtent,
              cacheExtent: _dateBarItemExtent * 8,
              itemCount: (_windowDaysHalf * 2) + 1,
              itemBuilder: (context, index) {
                final dayOffset = index - _windowDaysHalf;
                final date = _anchor.add(Duration(days: dayOffset));
                final key = Mark.ymd(date);
                return RepaintBoundary(
                  child: _DateTile(
                    date: date,
                    isSelected: key == selectedKey,
                    isToday: key == todayKey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _centerIndex(int index, {required bool animate}) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final itemStart = _dateBarPadding + index * _dateBarItemExtent;
    final itemCenter = itemStart + _dateBarItemExtent / 2;
    final target = (itemCenter - position.viewportDimension / 2).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (animate) {
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _controller.jumpTo(target);
    }
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.selectedDay});

  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 4),
      child: Row(
        children: [
          LiquidSurface(
            variant: LiquidVariant.accent,
            radius: 12,
            specular: false,
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDay),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Sheet days start 08:00 · ${HospitalTime.shiftFor(DateTime.now()).label} now',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          LiquidButton(
            onPressed: () => context.read<SheetCubit>().showToday(),
            style: LiquidButtonStyle.secondary,
            size: LiquidControlSize.compact,
            icon: const Icon(Icons.today_rounded, size: 16),
            child: const Text('Today'),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.date,
    required this.isSelected,
    required this.isToday,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;

  static final _weekday = DateFormat('EEE');
  static final _monthBadge = DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final foreground = isSelected ? cs.onPrimary : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: _dateBarItemSpacing),
      child: LiquidSurface(
        onTap: () => context.read<SheetCubit>().showDay(date),
        variant: isSelected
            ? LiquidVariant.accent
            : isToday
            ? LiquidVariant.inset
            : LiquidVariant.surface,
        tint: cs.primary,
        radius: 18,
        selected: isSelected,
        specular: !isSelected,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(
          width: _dateBarItemWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _weekday.format(date).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: isSelected ? 0.9 : 0.65),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 12,
                child: isToday
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.onPrimary.withValues(alpha: 0.9)
                              : cs.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(width: 5, height: 5),
                      )
                    : Text(
                        _monthBadge.format(date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          color: foreground.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
