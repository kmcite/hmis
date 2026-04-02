import 'package:hmis/main.dart';

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
  pediatrics,
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
      CaseType.pediatrics => 'Pediatrics',
      CaseType.minorOt => 'Minor OT',
      CaseType.rta => 'RTA',
      CaseType.dogBite => 'Dog Bites',
      CaseType.mlc => 'MLC',
      CaseType.postmortem => 'Autopsy',
    };
  }
}
