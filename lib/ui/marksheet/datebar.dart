import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/ui/home/settings.dart';
import 'package:intl/intl.dart';
import 'package:hmis/utils/datetime.dart';

const int _middleIndex = 1000;
const double _itemWidth = 60.0;
const double _itemPadding = 8.0;
const double _totalItemWidth = _itemWidth + _itemPadding;

class DateBar extends StatefulWidget {
  const DateBar({super.key});

  @override
  State<DateBar> createState() => _DateBarState();
}

class _DateBarState extends State<DateBar> {
  late final ScrollController _scrollController;
  late final ValueNotifier<DateTime> _visibleDateNotifier;
  late final DateTime _initialToday;
  final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _initialToday = DateTime(now.year, now.month, now.day);
    _visibleDateNotifier = ValueNotifier(shiftDateOf(now));
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(shiftDateOf(DateTime.now()), animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _visibleDateNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final centerOffset = _scrollController.offset + (screenWidth / 2) - 16;
    final index = (centerOffset - (_itemWidth / 2)) / _totalItemWidth;

    final date = _getDateForIndex(index.round());
    if (!_isSameDay(date, _visibleDateNotifier.value)) {
      _visibleDateNotifier.value = date;
    }
  }

  void _scrollToDate(DateTime date, {bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = dateOnly.difference(_initialToday).inDays;

    final index = _middleIndex + difference;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final offset =
        (index * _totalItemWidth) - (screenWidth / 2) + (_itemWidth / 2) + 16;

    if (animate) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }

  DateTime _getDateForIndex(int index) {
    return _initialToday.add(Duration(days: index - _middleIndex));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = shiftDateOf(DateTime.now());

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<DateTime>(
                  valueListenable: _visibleDateNotifier,
                  builder: (context, visibleDate, _) {
                    return Text(
                      _monthYearFormat.format(visibleDate),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: () {
                    context
                        .read<SettingsCubit>()
                        .onCurrentlySelectedDateChanged(today);
                    _scrollToDate(today);
                  },
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text('Today'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Horizontal scrollable dates
          Expanded(
            child: BlocBuilder<SettingsCubit, SettingsState>(
              buildWhen: (previous, current) =>
                  previous.currentlySelectedDate !=
                  current.currentlySelectedDate,
              builder: (context, settingsState) {
                final selectedDate = settingsState.currentlySelectedDate;
                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _middleIndex * 2,
                  itemExtent: _totalItemWidth,
                  itemBuilder: (context, index) {
                    final date = _getDateForIndex(index);
                    return _DateItem(
                      date: date,
                      isSelected: _isSameDay(date, selectedDate),
                      isToday: _isSameDay(date, today),
                      onTap: () {
                        context
                            .read<SettingsCubit>()
                            .onCurrentlySelectedDateChanged(date);
                        _scrollToDate(date);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  static final DateFormat _dayFormat = DateFormat('EEE');

  const _DateItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: _itemPadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _itemWidth,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : isToday
                ? colorScheme.primaryContainer.withOpacity(0.4)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isToday && !isSelected
                ? Border.all(
                    color: colorScheme.primary.withOpacity(0.5),
                    width: 1.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _dayFormat.format(date).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? colorScheme.onPrimary.withOpacity(0.8)
                      : theme.hintColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isSelected ? colorScheme.onPrimary : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

