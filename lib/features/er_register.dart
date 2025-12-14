import 'package:hmis/domain/domain.dart';
import 'package:hmis/main.dart';

class ErRegisterGrid extends StatelessWidget {
  final DateTime date;
  final List<CaseType> rows;
  final List<DutyShift> columns;

  /// callbacks (UI → domain)
  final int Function(CaseType row, DutyShift col) countOf;
  final void Function(CaseType row, DutyShift col) onTapCell;
  final void Function(CaseType row, DutyShift col)? onLongPressCell;

  const ErRegisterGrid({
    super.key,
    required this.date,
    required this.rows,
    required this.columns,
    required this.countOf,
    required this.onTapCell,
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
          return const SizedBox.shrink();
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
          onTap: () => onTapCell(type, shift),
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
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
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
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
