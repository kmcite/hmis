import 'package:hmis/main.dart';

class ErMarksheetGrid extends StatelessWidget {
  final DateTime date;
  final List<CaseType> rows;
  final List<DutyShift> columns;

  /// callbacks (UI -> domain)
  final int Function(CaseType row, DutyShift col) countOf;
  final void Function(CaseType row, DutyShift col) onTapCellToCreateMark;
  final void Function(CaseType row, DutyShift col)? onLongPressCell;

  const ErMarksheetGrid({
    super.key,
    required this.date,
    required this.rows,
    required this.columns,
    required this.countOf,
    required this.onTapCellToCreateMark,
    this.onLongPressCell,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount =
        columns.length + 2; // +1 for row header, +1 for total column

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      margin: const EdgeInsets.all(4),
      child: Column(
        children: [
          // Persistent Header Row
          _buildHeaderRow(context, columnCount),
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Data rows
                  ...rows.asMap().entries.map(
                    (entry) {
                      final rowIndex = entry.key;
                      final type = entry.value;
                      return _buildDataRow(
                        context,
                        type,
                        rowIndex,
                        columnCount,
                      );
                    },
                  ),
                  // Add padding to prevent footer overlap
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Persistent Footer Row
          _buildFooterRow(context, columnCount),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, int columnCount) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Corner cell
          Container(
            width: 60,
            height: 48,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
              ),
            ),
            child: _CornerCell(),
          ),
          // Column headers
          ...columns.map(
            (shift) => Expanded(
              child: _HeaderCell(
                label: shift.name.toUpperCase(),
                shiftIcon: _getShiftIcon(shift),
              ),
            ),
          ),
          // Total header
          Container(
            width: 60,
            height: 48,
            child: _HeaderCell(
              label: 'TOTAL',
              isTotal: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    CaseType type,
    int rowIndex,
    int columnCount,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Row header
          Container(
            width: 60,
            height: 48,
            child: _HeaderCell(
              label: type.label,
              caseTypeIcon: type.icon,
              caseTypeColor: type.color,
            ),
          ),
          // Data cells
          ...columns.map(
            (shift) => Expanded(
              child: _DataCell(
                value: countOf(type, shift),
                onTap: () => onTapCellToCreateMark(type, shift),
                onLongPress: onLongPressCell == null
                    ? null
                    : () => onLongPressCell!(type, shift),
                caseTypeColor: type.color,
              ),
            ),
          ),
          // Total cell
          Container(
            width: 60,
            height: 48,
            child: _SummaryCell(
              value: columns
                  .map((shift) => countOf(type, shift))
                  .reduce((a, b) => a + b),
              type: SummaryType.caseTypeTotal,
              color: type.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterRow(BuildContext context, int columnCount) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Total label
          Container(
            width: 60,
            height: 48,
            child: _HeaderCell(
              label: 'TOTAL',
              isTotal: true,
            ),
          ),
          // Shift totals
          ...columns.map(
            (shift) => Expanded(
              child: _SummaryCell(
                value: rows
                    .map((type) => countOf(type, shift))
                    .reduce((a, b) => a + b),
                type: SummaryType.shiftTotal,
              ),
            ),
          ),
          // Grand total
          Container(
            width: 60,
            height: 48,
            child: _SummaryCell(
              value: rows
                  .map(
                    (type) => columns
                        .map((shift) => countOf(type, shift))
                        .reduce((a, b) => a + b),
                  )
                  .reduce((a, b) => a + b),
              type: SummaryType.grandTotal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getShiftIcon(DutyShift shift) {
    switch (shift) {
      case DutyShift.morning:
        return Icons.wb_sunny;
      case DutyShift.evening:
        return Icons.wb_twilight;
      case DutyShift.night:
        return Icons.nights_stay;
    }
  }
}

enum SummaryType { shiftTotal, caseTypeTotal, grandTotal }

// Corner Cell (top-left)
class _CornerCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.grid_view,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
      ),
    );
  }
}

// Header Cell
class _HeaderCell extends StatelessWidget {
  final String label;
  final IconData? shiftIcon;
  final IconData? caseTypeIcon;
  final Color? caseTypeColor;
  final bool isTotal;

  const _HeaderCell({
    required this.label,
    this.shiftIcon,
    this.caseTypeIcon,
    this.caseTypeColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isTotal ? Colors.transparent : Colors.transparent,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (shiftIcon != null || caseTypeIcon != null)
              Icon(
                shiftIcon ?? caseTypeIcon,
                size: 14,
                color:
                    caseTypeColor ??
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            if (shiftIcon != null || caseTypeIcon != null)
              const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: shiftIcon != null || caseTypeIcon != null ? 10 : 11,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Cell
class _DataCell extends StatelessWidget {
  final int value;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color caseTypeColor;

  const _DataCell({
    required this.value,
    required this.onTap,
    this.onLongPress,
    required this.caseTypeColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = value > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            color: hasData
                ? caseTypeColor.withOpacity(0.1)
                : Colors.transparent,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Center(
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: hasData ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: hasData
                    ? caseTypeColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Summary Cell
class _SummaryCell extends StatelessWidget {
  final int value;
  final SummaryType type;
  final Color? color;

  const _SummaryCell({
    required this.value,
    required this.type,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;

    switch (type) {
      case SummaryType.grandTotal:
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        break;
      case SummaryType.shiftTotal:
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        break;
      case SummaryType.caseTypeTotal:
        textColor = color ?? Theme.of(context).colorScheme.onPrimaryContainer;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Center(
        child: Text(
          value.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: value > 99 ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
