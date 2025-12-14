import 'package:hmis/main.dart';
import 'package:hmis/utils/crud.dart';

@Entity()
class Patient {
  @Id(assignable: true)
  int id = 0;

  String name = '';
  String age = '';
  String diagnosis = '';

  String createdAt = '';
  final investigations = ToMany<Investigation>();

  @Transient()
  OutComeStatus outComeStatus = OutComeStatus.emergency;

  Patient copyWith({
    int? id,
    String? name,
    String? age,
    String? diagnosis,
    String? createdAt,
    OutComeStatus? outComeStatus,
  }) {
    return Patient()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..age = age ?? this.age
      ..diagnosis = diagnosis ?? this.diagnosis
      ..createdAt = createdAt ?? this.createdAt
      ..outComeStatus = outComeStatus ?? this.outComeStatus;
  }
}

class PatientsRepository with CRUD<Patient> {}

enum OutComeStatus {
  emergency,
  discharged,
  admitted,
  referred,
  expired;
}
