/// Returns the shift date for a given wall-clock [DateTime].
///
/// A "shift day" runs from 08:00 to the next calendar day 07:59.
/// Arrivals between 00:00–07:59 belong to the **previous** calendar day's shift.
/// This is the single source of truth — never duplicated inline.
DateTime shiftDateOf(DateTime dt) => dt.hour < 8
    ? DateTime(dt.year, dt.month, dt.day - 1)
    : DateTime(dt.year, dt.month, dt.day);

extension DateTimeExtension on DateTime {
  String format() => '${day}/${month}/${year}';
  String formattedDate() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
  }

  String formattedTime() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Wall-clock datetime for display on record rows: "26/04 · 01:30"
  String formattedDateTime() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')} · ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
