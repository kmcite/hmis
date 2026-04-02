import 'package:hmis/main.dart';

@Entity()
class Investigation {
  @Id(assignable: true)
  int id = 0;
  String name = '';
  int price = 200;
}
