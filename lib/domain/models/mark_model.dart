import 'package:flutter/cupertino.dart';
import 'package:pocketbase/pocketbase.dart';

// ---------------------------------------------------------------- enums

enum DutyShift {
  morning,
  evening,
  night;

  /// Throws on unknown input — a schema rename or typo must surface, not
  /// silently become a Morning mark on the register.
  static DutyShift parse(String v) => DutyShift.values.firstWhere(
    (e) => e.name == v,
    orElse: () => throw FormatException('Unknown DutyShift: $v'),
  );

  String get label => switch (this) {
    DutyShift.morning => 'Morning',
    DutyShift.evening => 'Evening',
    DutyShift.night => 'Night',
  };
}

enum CaseType {
  medical,
  surgical,
  pediatrics,
  minorOt,
  rta,
  dogBite,
  mlc,
  postmortem;

  static CaseType parse(String v) => CaseType.values.firstWhere(
    (e) => e.name == v,
    orElse: () => throw FormatException('Unknown CaseType: $v'),
  );

  String get label => switch (this) {
    CaseType.medical => 'Medical',
    CaseType.surgical => 'Surgical',
    CaseType.pediatrics => 'Pediatrics',
    CaseType.minorOt => 'Minor OT',
    CaseType.rta => 'RTA',
    CaseType.dogBite => 'Dog Bites',
    CaseType.mlc => 'MLC',
    CaseType.postmortem => 'Autopsy',
  };
}

// ---------------------------------------------------------------- model

const _unset = Object();

@immutable
class Mark {
  const Mark({
    this.id = '',
    required this.date,
    required this.shift,
    required this.caseType,
    this.patientName,
    this.ageYears,
    this.isMale,
    this.remarks,
    this.createdAt,
  });

  final String id;

  /// Sheet / duty day (starts 08:00) — marksheet column, not calendar midnight.
  final DateTime date;
  final DutyShift shift;
  final CaseType caseType;

  /// Nullable throughout: "not recorded" is a real value on a register and
  /// must not collapse into 0 / true / ''. ageYears == 0 is a real neonate.
  final String? patientName;
  final int? ageYears;
  final bool? isMale;
  final String? remarks;

  final DateTime? createdAt;

  bool get isPersisted => id.isNotEmpty;

  // ------------------------------------------------------- serialization

  factory Mark.fromRecord(RecordModel r) => Mark(
    id: r.id,
    date: parseYmd(r.get<String>('sheet_date')),
    shift: DutyShift.parse(r.get<String>('shift')),
    caseType: CaseType.parse(r.get<String>('case_type')),
    patientName: _orNull(r.get<String>('patient_name')),
    // Text column, not number — PocketBase coerces an unset number to 0,
    // which would make every unrecorded age indistinguishable from 0y.
    ageYears: int.tryParse(r.get<String>('age_years')),
    // Select column for the same reason: an unset bool reads back false.
    isMale: switch (r.get<String>('sex')) {
      'male' => true,
      'female' => false,
      _ => null,
    },
    remarks: _orNull(r.get<String>('remarks')),
    createdAt: DateTime.tryParse(r.get<String>('created'))?.toLocal(),
  );

  /// Empty strings rather than nulls — PocketBase rejects explicit null on
  /// text/select fields, and '' round-trips back to null via _orNull.
  Map<String, dynamic> toBody() => {
    'sheet_date': ymd(date),
    'shift': shift.name,
    'case_type': caseType.name,
    'patient_name': patientName ?? '',
    'age_years': ageYears?.toString() ?? '',
    'sex': switch (isMale) {
      true => 'male',
      false => 'female',
      null => '',
    },
    'remarks': remarks ?? '',
    // 'created' is server-owned — never sent.
  };

  static String? _orNull(String s) => s.trim().isEmpty ? null : s.trim();

  /// `YYYY-MM-DD` from local parts — never toIso8601String(), which would
  /// drag UTC offset into the sheet key.
  static String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Always yields local midnight, tolerant of a plain 'YYYY-MM-DD' or a
  /// full datetime, in case the column type ever changes.
  static DateTime parseYmd(String s) {
    final p = s.split(RegExp('[T ]')).first.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // ------------------------------------------------------------- helpers

  /// Required fields use `??`; nullable fields use the sentinel so
  /// copyWith(ageYears: null) clears rather than being ignored.
  Mark copyWith({
    String? id,
    DateTime? date,
    DutyShift? shift,
    CaseType? caseType,
    Object? patientName = _unset,
    Object? ageYears = _unset,
    Object? isMale = _unset,
    Object? remarks = _unset,
    DateTime? createdAt,
  }) => Mark(
    id: id ?? this.id,
    date: date == null ? this.date : dateOnly(date),
    shift: shift ?? this.shift,
    caseType: caseType ?? this.caseType,
    patientName: identical(patientName, _unset)
        ? this.patientName
        : patientName as String?,
    ageYears: identical(ageYears, _unset) ? this.ageYears : ageYears as int?,
    isMale: identical(isMale, _unset) ? this.isMale : isMale as bool?,
    remarks: identical(remarks, _unset) ? this.remarks : remarks as String?,
    createdAt: createdAt ?? this.createdAt,
  );

  /// Full-field equality — isDirty / canSave depend on it.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mark &&
          id == other.id &&
          date == other.date &&
          shift == other.shift &&
          caseType == other.caseType &&
          patientName == other.patientName &&
          ageYears == other.ageYears &&
          isMale == other.isMale &&
          remarks == other.remarks &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    date,
    shift,
    caseType,
    patientName,
    ageYears,
    isMale,
    remarks,
    createdAt,
  );

  @override
  String toString() =>
      'Mark($id, ${ymd(date)}, ${shift.name}, ${caseType.name})';
}

extension MarkX on Mark {
  String get info {
    final parts = [
      if (patientName != null) patientName!,
      if (ageYears != null) '${ageYears}y',
      if (isMale != null) sexLabel,
    ];
    return parts.isEmpty ? 'Patient details not recorded' : parts.join(', ');
  }

  String get sexLabel => switch (isMale) {
    true => 'M',
    false => 'F',
    null => '—',
  };
}
