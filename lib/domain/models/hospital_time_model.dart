import 'package:hmis/domain/models/mark_model.dart';
import 'package:hmis/services/datetime.dart';

/// Hospital duty calendar: sheet day starts 08:00; shifts 08–14 / 14–20 / 20–08.
abstract final class HospitalTime {
  static const int sheetRolloverHour = 8;

  static DateTime sheetDateFor(DateTime wallClock) => wallClock.shiftDateOf();

  static String sheetKeyFor(DateTime wallClock) =>
      Mark.ymd(sheetDateFor(wallClock));

  static DutyShift shiftFor(DateTime wallClock) {
    final h = wallClock.hour;
    if (h >= 8 && h < 14) return DutyShift.morning;
    if (h >= 14 && h < 20) return DutyShift.evening;
    return DutyShift.night;
  }

  static bool isBeforeSheetRollover(DateTime wallClock) =>
      wallClock.hour < sheetRolloverHour;

  static bool sheetDiffersFromArrival({
    required DateTime sheetDate,
    required DateTime arrival,
  }) {
    return Mark.ymd(Mark.dateOnly(sheetDate)) !=
        Mark.ymd(Mark.dateOnly(arrival));
  }

  static Mark newMarkAt(DateTime wall, {CaseType caseType = CaseType.medical}) =>
      Mark(
        date: sheetDateFor(wall),
        shift: shiftFor(wall),
        caseType: caseType,
        createdAt: wall,
      );
}

extension MarkHospitalTime on Mark {
  DateTime get sheetDate => Mark.dateOnly(date);

  DateTime? get arrivalAt => createdAt;

  bool get hasDistinctArrivalDay {
    final a = arrivalAt;
    if (a == null) return false;
    return HospitalTime.sheetDiffersFromArrival(sheetDate: sheetDate, arrival: a);
  }

  DateTime effectiveArrival({DateTime? wallFallback}) =>
      arrivalAt ?? wallFallback ?? DateTime.now();

  DutyShift get derivedShift => HospitalTime.shiftFor(effectiveArrival());

  Mark normalizedForSave({DateTime? wallFallback}) {
    final wall = effectiveArrival(wallFallback: wallFallback);
    return copyWith(
      date: HospitalTime.sheetDateFor(wall),
      shift: HospitalTime.shiftFor(wall),
      createdAt: wall,
    );
  }
}
