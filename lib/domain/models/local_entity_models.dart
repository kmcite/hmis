import 'package:objectbox/objectbox.dart';

/// ObjectBox persistence row for [Mark] — not used by UI directly.
@Entity()
class MarkEntity {
  MarkEntity({
    required this.clientId,
    this.remoteId,
    required this.sheetDateYmd,
    required this.dateMs,
    required this.shift,
    required this.caseType,
    this.patientName,
    this.ageYears,
    this.sexCode = -1,
    this.remarks,
    this.createdAtMs,
    required this.updatedAtMs,
    this.isDeleted = false,
  });

  @Id()
  int id = 0;

  @Unique(onConflict: ConflictStrategy.fail)
  String clientId;

  @Index()
  String? remoteId;

  @Index()
  String sheetDateYmd;

  int dateMs;
  String shift;
  String caseType;
  String? patientName;
  int? ageYears;
  int sexCode;
  String? remarks;
  int? createdAtMs;
  int updatedAtMs;
  bool isDeleted;
}

@Entity()
class OutboxEntry {
  OutboxEntry({
    required this.entityClientId,
    required this.operation,
    required this.createdAtMs,
    this.status = 0,
    this.attemptCount = 0,
    this.lastError,
  });

  @Id()
  int id = 0;

  @Index()
  String entityClientId;

  String operation;
  int status;
  int createdAtMs;
  int attemptCount;
  String? lastError;
}

@Entity()
class SyncMetaEntity {
  SyncMetaEntity({required this.key, required this.value});

  @Id()
  int id = 0;

  @Unique(onConflict: ConflictStrategy.replace)
  String key;

  String value;
}
