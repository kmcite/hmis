import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:hmis/models/er_mark.dart';

extension DutyShiftUi on DutyShift {
  IconData get icon => switch (this) {
    DutyShift.morning => Icons.wb_sunny,
    DutyShift.evening => Icons.wb_twilight,
    DutyShift.night => Icons.nightlight_round,
  };
}

extension CaseTypeUi on CaseType {
  IconData get icon => switch (this) {
    CaseType.medical => CupertinoIcons.lab_flask,
    CaseType.surgical => CupertinoIcons.bandage,
    CaseType.pediatrics => CupertinoIcons.person_2,
    CaseType.minorOt => CupertinoIcons.hammer,
    CaseType.rta => CupertinoIcons.car_detailed,
    CaseType.dogBite => CupertinoIcons.paw,
    CaseType.mlc => CupertinoIcons.shield,
    CaseType.postmortem => CupertinoIcons.doc_plaintext,
  };

  Color get color => switch (this) {
    CaseType.medical => CupertinoColors.systemBlue,
    CaseType.surgical => CupertinoColors.systemGreen,
    CaseType.pediatrics => CupertinoColors.systemPurple,
    CaseType.minorOt => CupertinoColors.systemOrange,
    CaseType.rta => CupertinoColors.systemRed,
    CaseType.dogBite => CupertinoColors.systemBrown,
    CaseType.mlc => CupertinoColors.systemIndigo,
    CaseType.postmortem => CupertinoColors.systemGrey,
  };
}
