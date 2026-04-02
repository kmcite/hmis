import 'package:forui/forui.dart';
import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/bussiness/marks/er_mark.dart';
import 'package:hmis/domain/er_mark.dart';
import 'package:hmis/main.dart';
import 'package:hmis/bussiness/navigation.dart';
import 'package:hmis/utils/redux.dart';
import 'package:yaru/yaru.dart';

class AddMarkDialog extends UI {
  const AddMarkDialog({super.key});
  @override
  void init() async {
    await Future.delayed(Duration(seconds: 1));
    dispatch(InitializeNewErMark());
  }

  @override
  void dispose() {
    dispatch(ClearNewErMark());
  }

  @override
  Widget build(context) {
    final mark = state.marks.markToCreate;
    if (mark == null)
      return Scaffold(
        body: Center(
          child: YaruCircularProgressIndicator(),
        ),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Mark'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .start,
          spacing: 8,
          children: [
            TextFormField(
              decoration: InputDecoration(
                label: Text('Name'),
              ),
              initialValue: mark.patientName,
              onChanged: (value) => dispatch(NewMarkPatientNameAction(value)),
            ),
            TextFormField(
              decoration: InputDecoration(
                label: Text('Notes'),
              ),
              initialValue: mark.remarks,
              onChanged: (value) => dispatch(NewMarkRemarksAction(value)),
              minLines: 8,
              maxLines: 8,
            ),

            TextFormField(
              decoration: InputDecoration(
                label: Text('Age'),
              ),
              initialValue: mark.ageYears.toString(),
              onChanged: (value) =>
                  dispatch(NewMarkAgeYearsAction(int.tryParse(value) ?? 0)),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (_, i) {
                  final type = DutyShift.values[i];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: type.index == mark.shift
                        ? IconButton.filled(
                            icon: Text(
                              type.name.capitalize.substring(0, 1),
                            ),
                            onPressed: () {},
                          )
                        : IconButton.filledTonal(
                            icon: Text(
                              type.name.capitalize.substring(0, 1),
                            ),
                            onPressed: () {
                              dispatch(NewMarkShiftAction(type));
                            },
                          ),
                  );
                },
                itemCount: DutyShift.values.length,
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (_, i) {
                  final type = CaseType.values[i];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GridTile(
                      child: Text(type.name),
                      footer: IconButton(
                        onPressed: () => dispatch(
                          NewMarkCaseTypeAction(type),
                        ),
                        icon: Icon(
                          type.index == mark.caseType
                              ? Icons.check
                              : Icons.circle,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: CaseType.values.length,
              ),
            ),
            Row(
              spacing: 8,
              children: [
                IconButton.filled(
                  onPressed: () {
                    final mark = state.marks.markToCreate;
                    // Initialize the mark with current date if not set
                    if (mark == null) return dispatch(Icon(Icons.abc));
                    if (mark.date.year == 0) {
                      final now = DateTime.now();
                      final normalizedDate = DateTime(
                        now.year,
                        now.month,
                        now.day,
                      );
                      dispatch(NewMarkDateAction(normalizedDate));
                    }
                    dispatch(PutMark(mark));
                    dispatch(NavigateBack());
                  },
                  icon: Icon(
                    FIcons.check,
                    color: Colors.green,
                  ),
                  // iconSize: 260,
                ),
                IconButton.filledTonal(
                  onPressed: () => dispatch(NavigateBack()),
                  icon: Icon(
                    FIcons.x,
                    color: Colors.red,
                  ),
                  // iconSize: 260,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
