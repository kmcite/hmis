import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/domain/er_mark.dart';
import 'package:hmis/main.dart';
import 'package:hmis/utils/redux.dart';

class CasePage extends UI {
  final ErMark mark;
  const CasePage(this.mark, {super.key});
  @override
  build(context) {
    final _mark = state.marks.all.firstWhere((i) => i.id == mark.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(_mark.patientName, textScaleFactor: 1.5),
        actions: [
          IconButton(
            onPressed: () {
              // dispatch(DeleteErMark(erMark));
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('NAME', textScaleFactor: 1.2),
            TextFormField(
              initialValue: _mark.patientName,
              onChanged: (name) {
                dispatch(PutMark(mark..patientName = name));
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
              ),
            ),
            Text('AGE'),
            TextFormField(
              initialValue: _mark.ageYears.toString(),
              onChanged: (age) {
                dispatch(PutMark(mark..ageYears = int.tryParse(age) ?? 0));
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake, color: Colors.blueAccent),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('investigations', textScaleFactor: 1.2),
                // PopupMenuButton(
                //   onSelected: (investigation) {
                //     // update(
                //     //   patient..investigations.add(investigation),
                //     // );
                //   },
                //   itemBuilder: (_) {
                //     return context.of<InvestigationsBloc>().investigations.map(
                //       (value) {
                //         return PopupMenuItem(
                //           value: value,
                //           child: Row(
                //             children: [
                //               // if (patient.investigations.any(
                //               //   (inv) => inv.id == value.id,
                //               // ))
                //               //   const Icon(Icons.done, color: Colors.green)
                //               // else
                //               //   const Icon(Icons.cancel, color: Colors.red),
                //               value.name.text().pad(),
                //             ],
                //           ),
                //         );
                //       },
                //     ).toList();
                //   },
                // ),
              ],
            ),
            // Wrap(
            //   children: patient.investigations
            //       .map(
            //         (eachInvestigaion) => Chip(
            //           labelPadding: const EdgeInsets.all(1),
            //           label: Text(eachInvestigaion.name),
            //           onDeleted: () {
            //             // update(
            //             //   patient..investigations.remove(eachInvestigaion),
            //             // );
            //           },
            //           backgroundColor: Colors.deepOrange,
            //         ),
            //       )
            //       .toList(),
            // ),
            Text(
              'NOTES',
              textScaleFactor: 1.2,
            ),
            // '${patient.investigations.fold(0, (i, s) => i + s.price)}'.text(),
            TextFormField(
              initialValue: _mark.remarks,
              onChanged: (value) {
                dispatch(PutMark(mark..remarks = value));
              },
              minLines: 3,
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }
}
