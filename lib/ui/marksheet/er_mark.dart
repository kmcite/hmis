import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';
import 'package:objectbox/objectbox.dart';

class ErMarkCubit extends Cubit<ErMark?> {
  final Store store;
  
  ErMarkCubit(this.store) : super(null);

  void onErMarkChanged(ErMark? erMark) {
    emit(erMark);
    if (erMark != null) store.put(erMark);
  }

  void changeName(String name) {
    if (state != null) {
      state!.patientName = name;
      onErMarkChanged(state);
    }
  }

  void changeAge(String age) {
    if (state != null) {
      state!.ageYears = int.tryParse(age) ?? 0;
      onErMarkChanged(state);
    }
  }

  void changeRemarks(String remarks) {
    if (state != null) {
      state!.remarks = remarks;
      onErMarkChanged(state);
    }
  }
}
