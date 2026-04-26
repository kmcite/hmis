import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/main.dart';

class ErMarkToDeleteCubit extends Cubit<ErMark?> {
  ErMarkToDeleteCubit() : super(null);

  void onMarkToDeleteChanged(ErMark? markToDelete) {
    emit(markToDelete);
  }
}
