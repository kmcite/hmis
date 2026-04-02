import 'package:hmis/main.dart';

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
}

enum OutComeStatus { emergency, discharged, admitted, referred, expired }
