import 'package:flutter/material.dart';
import 'package:hmis/controllers/current_date.dart';
import 'package:hmis/controllers/sheet.dart';
import 'package:hmis/models/models.dart';
import 'package:hmis/models/presentation.dart';
import 'package:hmis/ui/screens/new_chit_screen.dart';
import 'package:hmis/ui/dialogs/marksheet_grid_details.dart';
import 'package:hmis/ui/marksheet/datebar.dart';
import 'package:intl/intl.dart';
import 'package:navigation/navigation.dart';
import 'package:hmis/utils/router.dart';

class MarksheetScreen extends SignalConsumer {
  const MarksheetScreen({super.key});

  DutyShift _getCurrentShift() {
    final hour = DateTime.now().hour;
    if (hour >= 8 && hour < 14) return DutyShift.morning;
    if (hour >= 14 && hour < 20) return DutyShift.evening;
    return DutyShift.night;
  }

  IconData _getShiftIcon(DutyShift shift) {
    switch (shift) {
      case DutyShift.morning:
        return Icons.wb_sunny;
      case DutyShift.evening:
        return Icons.wb_twilight;
      case DutyShift.night:
        return Icons.nightlight_round;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheet = sheetController(context);
    final currentDate = currentDateController(context).date();

    // Pre-calculate the daily table once per build
    final table = sheet.table();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(DateFormat('d MMM yyyy').format(currentDate)),
        actions: [
          IconButton(
            onPressed: () => context.pushDialog(const NewChitScreen()),
            icon: const Icon(Icons.add_circle_outline),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DateBar(),
            _buildHeaderRow(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...CaseType.values.map(
                      (type) => _buildDataRow(context, type, currentDate, table),
                    ),
                    const SizedBox(height: 8),
                    _buildFooterRow(context, currentDate, table),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 48,
            child: Card(
              margin: const EdgeInsets.all(3),
              elevation: 0,
              color: theme.colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
          ...DutyShift.values.map(
            (shift) => Expanded(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.all(3),
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  height: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getShiftIcon(shift),
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shift.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            height: 48,
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.all(3),
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'TOTAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    CaseType type,
    DateTime currentDate,
    Map<CaseType, Map<DutyShift, int>> table,
  ) {
    final theme = Theme.of(context);
    final sheet = sheetController(context);
    final currentShift = _getCurrentShift();
    final typeColor = type.color;

    // Efficient lookup from pre-calculated table
    final rowMap = table[type]!;
    final rowTotal = rowMap.values.fold(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.all(3),
                color: typeColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: typeColor.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type.icon, size: 14, color: typeColor),
                    const SizedBox(height: 2),
                    Text(
                      type.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            ...DutyShift.values.map((shift) {
              final isCurrentShift = shift == currentShift;
              final count = rowMap[shift]!;
              return Expanded(
                child: GestureDetector(
                  onTap: () => sheet.markCase(type, shift),
                  onLongPress: () => context.pushDialog(
                    MarksheetGridDetailsDialog(
                      date: currentDate,
                      caseType: type,
                      dutyShift: shift,
                    ),
                  ),
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.all(3),
                    color: isCurrentShift
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: isCurrentShift
                          ? BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              width: 1.5,
                            )
                          : BorderSide.none,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: isCurrentShift ? 20 : 17,
                          fontWeight: FontWeight.w900,
                          color: isCurrentShift
                              ? theme.colorScheme.primary
                              : count > 0
                              ? theme.textTheme.bodyLarge?.color
                              : theme.disabledColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              width: 56,
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.all(3),
                color: rowTotal > 0
                    ? typeColor.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$rowTotal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: rowTotal > 0 ? typeColor : theme.disabledColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterRow(
    BuildContext context,
    DateTime currentDate,
    Map<CaseType, Map<DutyShift, int>> table,
  ) {
    final theme = Theme.of(context);
    // Grand total from pre-calculated table
    int grandTotal = 0;
    for (var row in table.values) {
      for (var count in row.values) {
        grandTotal += count;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 48,
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.all(3),
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'TOTAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          ...DutyShift.values.map((shift) {
            int shiftTotal = 0;
            for (var row in table.values) {
              shiftTotal += row[shift]!;
            }
            return Expanded(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.all(3),
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$shiftTotal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(
            width: 56,
            height: 48,
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.all(3),
              color: theme.colorScheme.primaryContainer.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$grandTotal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
