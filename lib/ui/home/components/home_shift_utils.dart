import 'package:hmis/domain/models/models.dart';

DutyShift homeActiveShift(DateTime clock) => HospitalTime.shiftFor(clock);
