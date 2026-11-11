import 'package:flutter/cupertino.dart';

// ---------------------------------------------------------------- enums

enum DutyShift {
  morning,
  evening,
  night;

  /// Throws on unknown input — a schema rename or typo must surface, not
  /// silently become a Morning entry on the register.
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
  dogBite,
  mlc,
  postmortem;

  /// `rta` and `minorOt` were merged into [surgical]; stored records with
  /// the legacy names still decode.
  static CaseType parse(String v) => switch (v) {
    'rta' || 'minorOt' || 'minor_ot' => CaseType.surgical,
    _ => CaseType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => throw FormatException('Unknown CaseType: $v'),
    ),
  };

  String get label => switch (this) {
    CaseType.medical => 'Medical',
    CaseType.surgical => 'Surgical',
    CaseType.pediatrics => 'Pediatrics',
    CaseType.dogBite => 'ARV - candidates',
    CaseType.mlc => 'MLC',
    CaseType.postmortem => 'Autopsy',
  };
}

// ---------------------------------------------------------------- model

const _unset = Object();

@immutable
class Patient {
  const Patient({
    this.id = '',
    required this.date,
    required this.shift,
    required this.caseType,
    this.patientName,
    this.ageYears,
    this.isMale,
    this.remarks,
    this.history,
    this.examination,
    this.management,
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

  /// Clinical note sections: history taking, on-examination, management.
  final String? history;
  final String? examination;
  final String? management;

  final DateTime? createdAt;

  bool get isPersisted => id.isNotEmpty;

  // ------------------------------------------------------- serialization

  /// JSON document stored in the shared database (`patients` collection).
  /// Nullable fields stay null — absent keys decode back to null.
  static Map<String, dynamic> toData(Patient m) => {
    'sheetDateYmd': ymd(m.date),
    'dateMs': dateOnly(m.date).millisecondsSinceEpoch,
    'shift': m.shift.name,
    'caseType': m.caseType.name,
    'patientName': m.patientName,
    'ageYears': m.ageYears,
    'isMale': m.isMale,
    'remarks': m.remarks,
    'history': m.history,
    'examination': m.examination,
    'management': m.management,
    'createdAtMs': m.createdAt?.millisecondsSinceEpoch,
  };

  factory Patient.fromData(String id, Map<String, dynamic> d) => Patient(
    id: id,
    date: DateTime.fromMillisecondsSinceEpoch(_int(d['dateMs'])),
    shift: DutyShift.parse(d['shift'] as String),
    caseType: CaseType.parse(d['caseType'] as String),
    patientName: d['patientName'] as String?,
    ageYears: (d['ageYears'] as num?)?.toInt(),
    isMale: d['isMale'] as bool?,
    remarks: d['remarks'] as String?,
    history: d['history'] as String?,
    examination: d['examination'] as String?,
    management: d['management'] as String?,
    createdAt: d['createdAtMs'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(_int(d['createdAtMs'])),
  );

  static int _int(Object? v) =>
      v is int ? v : v is num ? v.toInt() : int.parse('$v');

  /// `YYYY-MM-DD` from local parts — never toIso8601String(), which would
  /// drag UTC offset into the sheet key.
  static String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // ------------------------------------------------------------- helpers

  /// Required fields use `??`; nullable fields use the sentinel so
  /// copyWith(ageYears: null) clears rather than being ignored.
  Patient copyWith({
    String? id,
    DateTime? date,
    DutyShift? shift,
    CaseType? caseType,
    Object? patientName = _unset,
    Object? ageYears = _unset,
    Object? isMale = _unset,
    Object? remarks = _unset,
    Object? history = _unset,
    Object? examination = _unset,
    Object? management = _unset,
    DateTime? createdAt,
  }) => Patient(
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
    history: identical(history, _unset) ? this.history : history as String?,
    examination: identical(examination, _unset)
        ? this.examination
        : examination as String?,
    management: identical(management, _unset)
        ? this.management
        : management as String?,
    createdAt: createdAt ?? this.createdAt,
  );

  /// Full-field equality — isDirty / canSave depend on it.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Patient &&
          id == other.id &&
          date == other.date &&
          shift == other.shift &&
          caseType == other.caseType &&
          patientName == other.patientName &&
          ageYears == other.ageYears &&
          isMale == other.isMale &&
          remarks == other.remarks &&
          history == other.history &&
          examination == other.examination &&
          management == other.management &&
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
    history,
    examination,
    management,
    createdAt,
  );

  @override
  String toString() =>
      'Patient($id, ${ymd(date)}, ${shift.name}, ${caseType.name})';
}

extension PatientX on Patient {
  /// Quick marksheet adds carry no identity — they sit in the completion
  /// queue until a name (and ideally age/sex) is recorded.
  bool get needsDetails =>
      patientName == null || patientName!.trim().isEmpty;

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
