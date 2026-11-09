import 'package:hmis/domain/models/models.dart';

extension MarkEntityMapper on MarkEntity {
  Mark toDomain() {
    final sex = sexCode < 0
        ? null
        : sexCode == 1
        ? true
        : false;
    return Mark(
      id: remoteId ?? clientId,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      shift: DutyShift.parse(shift),
      caseType: CaseType.parse(caseType),
      patientName: patientName,
      ageYears: ageYears,
      isMale: sex,
      remarks: remarks,
      createdAt: createdAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(createdAtMs!),
    );
  }
}

MarkEntity markEntityFromDomain(
  Mark mark, {
  required String clientId,
  String? remoteId,
  int? updatedAtMs,
  bool isDeleted = false,
}) {
  final sexCode = mark.isMale == null
      ? -1
      : mark.isMale!
      ? 1
      : 0;
  return MarkEntity(
    clientId: clientId,
    remoteId: remoteId,
    sheetDateYmd: Mark.ymd(mark.date),
    dateMs: Mark.dateOnly(mark.date).millisecondsSinceEpoch,
    shift: mark.shift.name,
    caseType: mark.caseType.name,
    patientName: mark.patientName,
    ageYears: mark.ageYears,
    sexCode: sexCode,
    remarks: mark.remarks,
    createdAtMs: mark.createdAt?.millisecondsSinceEpoch,
    updatedAtMs:
        updatedAtMs ?? mark.createdAt?.millisecondsSinceEpoch ?? nowMs(),
    isDeleted: isDeleted,
  );
}

int nowMs() => DateTime.now().millisecondsSinceEpoch;
