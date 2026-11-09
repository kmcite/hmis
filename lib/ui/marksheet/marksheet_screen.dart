import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/new_chit_cubit.dart';
import 'package:hmis/business/sheet_cubit.dart';
import 'package:hmis/ui/shared/widgets/hmis_empty_state.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';
import 'package:hmis/ui/shared/dialogs/marksheet_grid_details.dart';
import 'package:hmis/ui/marksheet/components/datebar.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:intl/intl.dart';

Widget _marksheetCell(
  BuildContext context, {
  required Widget child,
  Color? tint,
  bool highlighted = false,
  double? height,
}) {
  return LiquidSurface(
    variant: highlighted ? LiquidVariant.accent : LiquidVariant.surface,
    tint: tint,
    selected: highlighted,
    radius: 10,
    specular: false,
    margin: const EdgeInsets.all(3),
    child: height != null
        ? SizedBox(height: height, child: Center(child: child))
        : Center(child: child),
  );
}

class MarksheetScreen extends StatelessWidget {
  const MarksheetScreen({super.key});
  DutyShift _getCurrentShift() => HospitalTime.shiftFor(DateTime.now());

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
    final sheet = context.watch<SheetCubit>().state;
    final sheetDay = sheet.selectedDay;
    final table = sheet.table;
    final sheetCubit = context.read<SheetCubit>();

    return LiquidScaffold(
      appBar: LiquidAppBar(
        title: 'Marksheet · ${DateFormat('d MMM yyyy').format(sheetDay)}',
        actions: [
          LiquidIconButton(
            icon: Icons.add_circle_outline,
            tooltip: 'New case',
            onPressed: () {
              context.read<NewChitCubit>().init();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewChitScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: sheet.loading && sheet.marks.isEmpty
            ? const LiquidProgress(message: 'Loading marksheet…')
            : sheet.error != null && sheet.marks.isEmpty
            ? HmisEmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load marksheet',
                subtitle: sheet.error.toString(),
                actionLabel: 'Retry',
                onAction: sheetCubit.refresh,
              )
            : Column(
                children: [
                  const DateBar(),
                  _buildHeaderRow(context),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => sheetCubit.refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            ...CaseType.values.map(
                              (type) => _buildDataRow(
                                context,
                                type,
                                sheetDay,
                                table,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildFooterRow(context, sheetDay, table),
                            const SizedBox(height: 20),
                          ],
                        ),
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
            child: _marksheetCell(context, height: 48, child: const SizedBox()),
          ),
          ...DutyShift.values.map(
            (shift) => Expanded(
              child: _marksheetCell(
                context,
                tint: theme.colorScheme.primary,
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
          SizedBox(
            width: 56,
            height: 48,
            child: _marksheetCell(
              context,
              tint: theme.colorScheme.primary,
              height: 48,
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
    final sheet = context.read<SheetCubit>();
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
              child: _marksheetCell(
                context,
                tint: typeColor,
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
                  onTap: () => sheet.markCase(type),
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (_) => MarksheetGridDetailsDialog(
                      date: currentDate,
                      caseType: type,
                      dutyShift: shift,
                    ),
                  ),
                  child: _marksheetCell(
                    context,
                    tint: theme.colorScheme.primary,
                    highlighted: isCurrentShift,
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
              );
            }),
            SizedBox(
              width: 56,
              child: _marksheetCell(
                context,
                tint: typeColor,
                highlighted: rowTotal > 0,
                child: Text(
                  '$rowTotal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: rowTotal > 0 ? typeColor : theme.disabledColor,
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
            child: _marksheetCell(
              context,
              tint: theme.colorScheme.primary,
              height: 48,
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
          ...DutyShift.values.map((shift) {
            int shiftTotal = 0;
            for (var row in table.values) {
              shiftTotal += row[shift]!;
            }
            return Expanded(
              child: _marksheetCell(
                context,
                tint: theme.colorScheme.primary,
                child: Text(
                  '$shiftTotal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          }),
          SizedBox(
            width: 56,
            height: 48,
            child: _marksheetCell(
              context,
              tint: theme.colorScheme.primary,
              highlighted: true,
              height: 48,
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
        ],
      ),
    );
  }
}
