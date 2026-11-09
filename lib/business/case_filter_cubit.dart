import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CaseRegisterFilter { casesByDay, allCases }

class CaseFilterState extends Equatable {
  const CaseFilterState({this.filter = CaseRegisterFilter.casesByDay});

  final CaseRegisterFilter filter;

  CaseFilterState copyWith({CaseRegisterFilter? filter}) =>
      CaseFilterState(filter: filter ?? this.filter);

  @override
  List<Object?> get props => [filter];
}

class CaseFilterCubit extends Cubit<CaseFilterState> {
  CaseFilterCubit() : super(const CaseFilterState());

  void setFilter(CaseRegisterFilter f) => emit(state.copyWith(filter: f));

  void toggle() => emit(
        state.copyWith(
          filter: state.filter == CaseRegisterFilter.casesByDay
              ? CaseRegisterFilter.allCases
              : CaseRegisterFilter.casesByDay,
        ),
      );

}
