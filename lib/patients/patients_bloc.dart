import 'package:hmis/main.dart';
import 'package:hmis/patients/patients.dart';

class PatientsBloc with ChangeNotifier {
  PatientsRepository get patientsRepository => context.of();

  final BuildContext context;
  PatientsBloc(this.context);

  late List<Patient> patients = patientsRepository.getAll();

  void put(Patient p) {
    patientsRepository.put(p);
    patients = patientsRepository.getAll();
    notifyListeners();
  }

  Patient get(int id) => patients.where((p) => p.id == id).first;
}
