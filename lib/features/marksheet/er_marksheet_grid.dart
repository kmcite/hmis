import 'package:hmis/domain/er_mark.dart';
import 'package:hmis/main.dart';

class ErMarksheetGrid extends StatelessWidget {
  final DateTime date;
  final List<CaseType> rows;
  final List<DutyShift> columns;

  /// callbacks (UI → domain)
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
    final columnCount = columns.length + 1; // +1 for row header
    final rowCount = rows.length + 1; // +1 for column header
    final totalCells = columnCount * rowCount;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: 1.4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final row = index ~/ columnCount;
        final col = index % columnCount;

        // Top-left empty corner
        if (row == 0 && col == 0) {
          return _HeaderCell(
            label: 'Shift Type',
          );
        }

        // Column headers
        if (row == 0) {
          final shift = columns[col - 1];
          return _HeaderCell(label: shift.name.toUpperCase());
        }

        // Row headers
        if (col == 0) {
          final type = rows[row - 1];
          return _HeaderCell(label: type.label);
        }

        // Data cell
        final type = rows[row - 1];
        final shift = columns[col - 1];
        final count = countOf(type, shift);

        return _DataCell(
          value: count,
          onTap: () => onTapCellToCreateMark(type, shift),
          onLongPress: onLongPressCell == null
              ? null
              : () => onLongPressCell!(type, shift),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final int value;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DataCell({
    required this.value,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Center(
        child: Text(
          value.toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
