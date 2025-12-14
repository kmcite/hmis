import 'package:hmis/utils/crud.dart';

import '../main.dart';

@Entity()
class Investigation {
  @Id(assignable: true)
  int id = 0;
  String name = '';
  int price = 200;
}

class InvestigationsRepository with CRUD<Investigation> {}

class InvestigationsBloc with ChangeNotifier {
  InvestigationsRepository get investigationsRepository =>
      InvestigationsRepository();

  BuildContext context;
  InvestigationsBloc(this.context);

  late List<Investigation> investigations = investigationsRepository.getAll();

  void put(Investigation investigation) {
    investigationsRepository.put(investigation);
    investigations = investigationsRepository.getAll();
    notifyListeners();
  }

  void remove(int id) {
    investigationsRepository.remove(id);
    investigations = investigationsRepository.getAll();
    notifyListeners();
  }
}
