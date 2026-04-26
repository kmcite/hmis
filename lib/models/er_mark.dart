import 'package:flutter/cupertino.dart';
import 'package:objectbox/objectbox.dart';

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
  bool isMale = true;
  String remarks = '';

  /// Audit
  DateTime createdAt = DateTime.now();

  ErMark({
    this.patientName = '',
    this.ageYears = 0,
    this.isMale = true,
    this.remarks = '',
  });
}

extension ErMarkX on ErMark {
  String get info {
    final parts = <String>[];
    if (patientName.isNotEmpty) {
      parts.add(patientName);
    }
    if (ageYears > 0) {
      parts.add('${ageYears}y');
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Patient details not recorded';
  }
}

enum DutyShift {
  morning,
  evening,
  night,
}

extension DutyShiftExtension on DutyShift {
  String get label {
    return switch (this) {
      DutyShift.morning => 'Morning',
      DutyShift.evening => 'Evening',
      DutyShift.night => 'Night',
    };
  }
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

  IconData get icon {
    switch (this) {
      case CaseType.medical:
        return CupertinoIcons.lab_flask;
      case CaseType.surgical:
        return CupertinoIcons.bandage;
      case CaseType.pediatrics:
        return CupertinoIcons.person_2;
      case CaseType.minorOt:
        return CupertinoIcons.hammer;
      case CaseType.rta:
        return CupertinoIcons.car_detailed;
      case CaseType.dogBite:
        return CupertinoIcons.paw;
      case CaseType.mlc:
        return CupertinoIcons.shield;
      case CaseType.postmortem:
        return CupertinoIcons.doc_plaintext;
    }
  }

  Color get color {
    switch (this) {
      case CaseType.medical:
        return CupertinoColors.systemBlue;
      case CaseType.surgical:
        return CupertinoColors.systemGreen;
      case CaseType.pediatrics:
        return CupertinoColors.systemPurple;
      case CaseType.minorOt:
        return CupertinoColors.systemOrange;
      case CaseType.rta:
        return CupertinoColors.systemRed;
      case CaseType.dogBite:
        return CupertinoColors.systemBrown;
      case CaseType.mlc:
        return CupertinoColors.systemIndigo;
      case CaseType.postmortem:
        return CupertinoColors.systemGrey;
    }
  }
}
