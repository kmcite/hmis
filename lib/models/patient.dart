import 'package:flutter/foundation.dart';
import 'package:hmis/models/models.dart';

@immutable
class Patient({
  required final String id,
  required final String name,
  required final String notes,
  required final DateTime date,
  final caseType = CaseType.medical,
  final shift = DutyShift.morning,
  final isMale = false,
  required final int age,
});

extension PatientApi on Patient {
  Patient copyWith({
    String? id,
    String? name,
    String? notes,
    DateTime? date,
    CaseType? caseType,
    DutyShift? shift,
    bool? isMale,
    int? age,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      caseType: caseType ?? this.caseType,
      shift: shift ?? this.shift,
      isMale: isMale ?? this.isMale,
      age: age ?? this.age,
    );
  }

  Mark toMark() => Mark(
    id: id,
    date: date,
    shift: shift,
    caseType: caseType,
    patientName: name,
    isMale: isMale,
    ageYears: age,
    remarks: notes,
  );
}
