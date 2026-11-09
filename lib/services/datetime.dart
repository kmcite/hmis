/// Wall-clock formatting and the hospital **sheet day** (starts 08:00 local).
///
/// Between 00:00–07:59 the sheet still belongs to the previous calendar day
/// (night shift). [createdAt] on [Mark] keeps the real arrival instant.

extension DateTimeExtension on DateTime {
  DateTime shiftDateOf() => hour < 8
      ? DateTime(year, month, day).subtract(const Duration(days: 1))
      : DateTime(year, month, day);

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
