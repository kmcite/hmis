import 'package:forui/forui.dart';
import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/domain/er_mark.dart';
import 'package:hmis/features/er_case_register.dart';
import 'package:hmis/features/marksheet/add_mark.dart';
import 'package:hmis/features/marksheet/er_marksheet_grid.dart';
import 'package:hmis/features/marksheet/datebar.dart';
import 'package:hmis/features/on_duty_doctor.dart';
import 'package:hmis/main.dart';
import 'package:hmis/bussiness/navigation.dart';
import 'package:hmis/bussiness/settings.dart';
import 'package:hmis/utils/redux.dart';

class Marksheet extends UI {
  @override
  Widget build(context) {
    final totalCount = state.marks.totalCountForDate(state.settings.date);
    final dateStr =
        "${state.settings.date.day}/${state.settings.date.month}/${state.settings.date.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Mark Sheet - $dateStr (Total: $totalCount)"),
      ),
      body: Column(
        children: [
          DateBar(
            selectedDate: state.settings.date,
            onDateSelected: (date) {
              dispatch(DateAction(date));
            },
          ),
          Expanded(
            child: ErMarksheetGrid(
              date: state.settings.date,
              rows: CaseType.values,
              columns: DutyShift.values,
              countOf: (type, shift) {
                final count = state.marks.cellCount(
                  date: state.settings.date,
                  shift: shift,
                  caseType: type,
                );
                return count;
              },
              onTapCellToCreateMark: (type, shift) {
                dispatch(CreateNewMarkAction(shift, type));
              },
              onLongPressCell: (type, shift) {
                dispatch(
                  ShowDialog(
                    CellDetails(
                      date: state.settings.date,
                      caseType: type,
                      dutyShift: shift,
                    ),
                  ),
                );
                dispatch(UndoMarkAction());
              },
            ),
          ),
          Text(
            totalCount.toString(),
            style: TextStyle(fontSize: 96),
          ),
        ],
      ),
      bottomNavigationBar: FHeader(
        suffixes: [
          FButton(
            onPress: () => dispatch(NavigateTo(Home())),
            child: Icon(Icons.home),
          ),
          FButton(
            onPress: () => dispatch(NavigateTo(AddMarkDialog())),
            child: Icon(Icons.add),
          ),
          FButton(
            onPress: () => dispatch(NavigateTo(ErCaseRegister())),
            child: Icon(Icons.list),
          ),
          FButton(
            onPress: () => dispatch(NavigateTo(SettingsScreen())),
            child: Icon(Icons.settings),
          ),
          FButton(
            onPress: () => dispatch(NavigateTo(OnDutyDoctor())),
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

class CellDetails extends UI {
  final DateTime date;
  final CaseType caseType;
  final DutyShift dutyShift;
  CellDetails({
    required this.date,
    required this.caseType,
    required this.dutyShift,
  });
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        "$caseType - $dutyShift on ${date.day}/${date.month}/${date.year}",
      ),
      children: [
        ...state.marks
            .cellPatients(date: date, shift: dutyShift, caseType: caseType)
            .map(
              (mark) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(mark.id.toString()),
                        Text(mark.patientName),
                        Text(mark.ageYears.toString()),
                        Text(mark.remarks),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}
