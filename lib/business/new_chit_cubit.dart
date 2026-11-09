import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/marks_repository.dart';

class NewChitState extends Equatable {
  const NewChitState({this.mark});

  final Mark? mark;

  NewChitState copyWith({Mark? mark}) => NewChitState(mark: mark ?? this.mark);

  @override
  List<Object?> get props => [mark];
}

class NewChitCubit extends Cubit<NewChitState> {
  NewChitCubit(this._repository) : super(const NewChitState());

  final MarksRepository _repository;

  void init() {
    emit(NewChitState(mark: HospitalTime.newMarkAt(DateTime.now())));
  }

  void onDate(DateTime date) =>
      emit(state.copyWith(mark: state.mark?.copyWith(date: date)));

  void onCaseType(CaseType caseType) =>
      emit(state.copyWith(mark: state.mark?.copyWith(caseType: caseType)));

  void onPatientName(String patientName) => emit(
    state.copyWith(mark: state.mark?.copyWith(patientName: patientName)),
  );

  void onAgeInYears(String ageYears) => emit(
    state.copyWith(
      mark: state.mark?.copyWith(ageYears: int.tryParse(ageYears) ?? 0),
    ),
  );

  void onIsMale(bool isMale) =>
      emit(state.copyWith(mark: state.mark?.copyWith(isMale: isMale)));

  void onRemarks(String remarks) =>
      emit(state.copyWith(mark: state.mark?.copyWith(remarks: remarks)));

  void onCreatedAt(DateTime time) =>
      emit(state.copyWith(mark: state.mark?.copyWith(createdAt: time)));

  Future<void> save() async {
    final m = state.mark;
    if (m == null) return;
    final wall = DateTime.now();
    await _repository.add(m.normalizedForSave(wallFallback: wall));
  }
}
