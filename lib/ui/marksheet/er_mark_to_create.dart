import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';
import 'package:objectbox/objectbox.dart';

class ErMarkToCreateCubit extends Cubit<ErMark?> {
  final Store store;

  ErMarkToCreateCubit(this.store) : super(null);

  /// MUTATIONS
  void onErMarkChanged(ErMark? erMark) {
    emit(erMark);
  }

  void create() {
    onErMarkChanged(ErMark());
  }

  void clear() {
    onErMarkChanged(null);
  }

  void changeShift(DutyShift shift) {
    onErMarkChanged(state?..shift = shift.index);
  }

  void changeCaseType(CaseType caseType) {
    onErMarkChanged(state?..caseType = caseType.index);
  }

  void changePatientName(String patientName) {
    onErMarkChanged(state?..patientName = patientName);
  }

  void changeAgeYears(String ageYears) {
    onErMarkChanged(state?..ageYears = int.tryParse(ageYears) ?? 0);
  }

  void changeRemarks(String remarks) {
    onErMarkChanged(state?..remarks = remarks);
  }

  void changeDate(DateTime date) {
    onErMarkChanged(state?..date = date);
  }

  void save() {
    if (state != null) {
      store.put(state!);
    }
  }
}
