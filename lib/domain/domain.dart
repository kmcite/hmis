// import 'package:hmis/main.dart';
import 'package:flutter/foundation.dart';
import 'package:hmis/objectbox.g.dart';
import 'package:hmis/utils/crud.dart';
import 'package:hmis/utils/single.dart';

@Entity()
class ErMark {
  @Id()
  int id = 0;

  /// Date-only (00:00) → one paper sheet
  @Index()
  DateTime date = DateTime.now();

  /// DutyShift.index → paper column
  @Index()
  int shift = 0;

  /// CaseType.index → paper row
  @Index()
  int caseType = 0;

  /// Optional patient details
  String patientName = '';
  int ageYears = 0;
  String remarks = '';

  /// Audit
  DateTime createdAt = DateTime.now();

  ErMark();
}

enum DutyShift {
  morning,
  evening,
  night,
}

enum CaseType {
  medical,
  surgical,
  minorOt,
  rta,
  dogBite,
  mlc,
  postmortem
  ;

  String get label {
    return switch (this) {
      CaseType.medical => 'Medical',
      CaseType.surgical => 'Surgical',
      CaseType.minorOt => 'Minor OT',
      CaseType.rta => 'RTA',
      CaseType.dogBite => 'Dog Bite',
      CaseType.mlc => 'MLC',
      CaseType.postmortem => 'Autopsy',
    };
  }
}

class Settings {
  DateTime date = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
    };
  }

  Settings();
  Settings.fromJson(Map<String, dynamic> json) {
    if (json['date'] != null) {
      date = DateTime.fromMillisecondsSinceEpoch(json['date']);
    }
  }
}

class ErRegisterRepository extends ChangeNotifier
    with CRUD<ErMark>, Single<Settings> {
  /// normalize date to 00:00
  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  String get key => 'Settings';
  @override
  Map<String, dynamic> toJson(Settings value) => value.toJson();

  @override
  Settings fromJson(Map<String, dynamic> json) => Settings.fromJson(json);

  /// mark one patient attended
  void markPatient({
    required DateTime date,
    required DutyShift shift,
    required CaseType caseType,
    String patientName = '',
    int ageYears = 0,
    String remarks = '',
  }) {
    put(
      ErMark()
        ..date = _day(date)
        ..shift = shift.index
        ..caseType = caseType.index
        ..patientName = patientName
        ..ageYears = ageYears
        ..remarks = remarks
        ..createdAt = DateTime.now(),
    );
    notifyListeners();
  }

  /// entire ER sheet (one paper)
  List<ErMark> dailySheet(DateTime date) {
    final d = _day(date);

    return box
        .query(ErMark_.date.equals(d.millisecondsSinceEpoch))
        .build()
        .find();
  }

  /// exact paper cell count
  int cellCount({
    required DateTime date,
    required DutyShift shift,
    required CaseType caseType,
  }) {
    final d = _day(date);

    return box
        .query(
          ErMark_.date.equals(d.millisecondsSinceEpoch) &
              ErMark_.shift.equals(shift.index) &
              ErMark_.caseType.equals(caseType.index),
        )
        .build()
        .count();
  }

  /// full ER table (rows × columns)
  Map<CaseType, Map<DutyShift, int>> dailyTable(DateTime date) {
    final marks = dailySheet(date);

    final table = {
      for (final c in CaseType.values)
        c: {
          for (final s in DutyShift.values) s: 0,
        },
    };

    for (final m in marks) {
      final c = CaseType.values[m.caseType];
      final s = DutyShift.values[m.shift];
      table[c]![s] = table[c]![s]! + 1;
    }

    return table;
  }

  /// list patients in one paper cell
  List<ErMark> cellPatients({
    required DateTime date,
    required DutyShift shift,
    required CaseType caseType,
  }) {
    final d = _day(date);

    return box
        .query(
          ErMark_.date.equals(d.millisecondsSinceEpoch) &
              ErMark_.shift.equals(shift.index) &
              ErMark_.caseType.equals(caseType.index),
        )
        .build()
        .find();
  }
}
