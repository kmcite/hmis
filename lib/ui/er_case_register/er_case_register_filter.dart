import 'package:flutter_bloc/flutter_bloc.dart';

enum CaseRegisterFilter { allCases, casesByDay }

class ErCaseRegisterFilterCubit extends Cubit<CaseRegisterFilter> {
  ErCaseRegisterFilterCubit() : super(CaseRegisterFilter.allCases);

  void changeFilter(CaseRegisterFilter newFilter) {
    emit(newFilter);
  }
}
