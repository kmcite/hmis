import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/patients_repository.dart';

class NewChitState extends Equatable {
  const NewChitState({this.patient});

  final Patient? patient;

  NewChitState copyWith({Patient? patient}) => NewChitState(patient: patient ?? this.patient);

  @override
  List<Object?> get props => [patient];
}

class NewChitCubit extends Cubit<NewChitState> {
  NewChitCubit(this._repository) : super(const NewChitState());

  final PatientsRepository _repository;

  void init() {
    emit(NewChitState(patient: HospitalTime.newPatientAt(DateTime.now())));
  }

  void onDate(DateTime date) =>
      emit(state.copyWith(patient: state.patient?.copyWith(date: date)));

  void onCaseType(CaseType caseType) =>
      emit(state.copyWith(patient: state.patient?.copyWith(caseType: caseType)));

  void onPatientName(String patientName) => emit(
    state.copyWith(patient: state.patient?.copyWith(patientName: patientName)),
  );

  void onAgeInYears(String ageYears) => emit(
    state.copyWith(
      patient: state.patient?.copyWith(ageYears: int.tryParse(ageYears) ?? 0),
    ),
  );

  void onIsMale(bool? isMale) => emit(
    state.copyWith(patient: state.patient?.copyWith(isMale: isMale)),
  );

  void onRemarks(String remarks) =>
      emit(state.copyWith(patient: state.patient?.copyWith(remarks: remarks)));

  void onHistory(String history) => emit(
    state.copyWith(patient: state.patient?.copyWith(history: history)),
  );

  void onExamination(String examination) => emit(
    state.copyWith(patient: state.patient?.copyWith(examination: examination)),
  );

  void onManagement(String management) => emit(
    state.copyWith(patient: state.patient?.copyWith(management: management)),
  );

  void onCreatedAt(DateTime time) =>
      emit(state.copyWith(patient: state.patient?.copyWith(createdAt: time)));

  Future<void> save() async {
    final m = state.patient;
    if (m == null) return;
    final wall = DateTime.now();
    await _repository.add(m.normalizedForSave(wallFallback: wall));
  }
}
