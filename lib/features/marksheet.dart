import 'package:hmis/domain/domain.dart';
import 'package:hmis/features/er_register.dart';
import 'package:hmis/main.dart';
import 'package:hmis/utils/datetime.dart';
import 'package:hmis/utils/router.dart';

class Marksheet extends StatefulWidget {
  @override
  State<Marksheet> createState() => _MarksheetState();
}

class _MarksheetState extends State<Marksheet> {
  late ErRegisterRepository erRegisterRepository = watch();
  DateTime date = DateTime.now();
  void onYesterdayed() {
    setState(() => date = date.subtract(Duration(days: 1)));
  }

  void onRefreshed() {
    setState(() => date = DateTime.now());
  }

  void onTomorrowed() {
    setState(() => date = date.add(Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(date.format()),
        actions: [
          IconButton(
            onPressed: onYesterdayed,
            icon: Icon(Icons.arrow_circle_left),
          ),
          IconButton(
            onPressed: onRefreshed,
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: onTomorrowed,
            icon: Icon(Icons.arrow_circle_right),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        spacing: 8,
        children: [
          Expanded(
            child: ErRegisterGrid(
              date: date,
              rows: CaseType.values,
              columns: DutyShift.values,
              countOf: (type, shift) => erRegisterRepository.cellCount(
                date: date,
                caseType: type,
                shift: shift,
              ),
              onTapCell: (type, shift) {
                erRegisterRepository.markPatient(
                  date: date,
                  shift: shift,
                  caseType: type,
                );
              },
              onLongPressCell: (type, shift) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              onPressed: () {
                find<Router>().goToErCaseRegister();
              },
              child: Text('View All Cases'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddMarkDialog extends StatefulWidget {
  final CaseType caseType;
  final DutyShift shift;
  const AddMarkDialog({super.key, required this.caseType, required this.shift});

  @override
  State<AddMarkDialog> createState() => _AddMarkDialogState();
}

class _AddMarkDialogState extends State<AddMarkDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Column(
        children: [
          Text('Add Mark'),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  router.goToMarkSheet();
                },
                child: Text('Cancel'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              final erRegisterRepository = find<ErRegisterRepository>();
              erRegisterRepository.markPatient(
                caseType: widget.caseType,
                shift: widget.shift,
                date: DateTime.now(),
              );
              find<Router>().goToMarkSheet();
            },
            child: Text('Add Mark'),
          ),
        ],
      ),
    );
  }
}
