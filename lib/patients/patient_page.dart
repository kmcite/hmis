import 'package:hmis/main.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key, required this.id});

  final int id;

  static const name = 'patient';

  @override
  Widget build(BuildContext context) {
    //   final patient = context.of<PatientsBloc>().get(id);
    //   final update = context.of<PatientsBloc>().put;
    //   return Scaffold(
    //     appBar: CustomAppBar(
    //       leading: IconButton(
    //         onPressed: () => context.pop(),
    //         icon: const FaIcon(
    //           FontAwesomeIcons.heartPulse,
    //           color: Colors.redAccent,
    //         ),
    //       ),
    //       title: Text(patient.name, textScaleFactor: 1.5).data!,
    //     ),
    //     body: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         children: [
    //           Text(
    //             'name',
    //             textScaleFactor: 1.2,
    //           ),
    //           TextFormField(
    //             initialValue: patient.name,
    //             onChanged: (name) => update(patient.copyWith(name: name)),
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
    //             ),
    //           ),
    //           'age'.text(textScaleFactor: 1.2).pad(),
    //           TextFormField(
    //             initialValue: patient.age,
    //             onChanged: (age) => update(patient.copyWith(age: age)),
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               prefixIcon: Icon(Icons.cake, color: Colors.blueAccent),
    //             ),
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             children: [
    //               Text('investigations', textScaleFactor: 1.2),
    //               PopupMenuButton(
    //                 onSelected: (investigation) => update(
    //                   patient..investigations.add(investigation),
    //                 ),
    //                 itemBuilder: (_) =>
    //                     context.of<InvestigationsBloc>().investigations.map(
    //                   (value) {
    //                     return PopupMenuItem(
    //                       value: value,
    //                       child: Row(
    //                         children: [
    //                           if (patient.investigations.any(
    //                             (inv) => inv.id == value.id,
    //                           ))
    //                             const Icon(Icons.done, color: Colors.green)
    //                           else
    //                             const Icon(Icons.cancel, color: Colors.red),
    //                           value.name.text().pad(),
    //                         ],
    //                       ),
    //                     );
    //                   },
    //                 ).toList(),
    //               ),
    //             ],
    //           ),
    //           Wrap(
    //             children: patient.investigations
    //                 .map(
    //                   (eachInvestigaion) => Chip(
    //                     labelPadding: const EdgeInsets.all(1),
    //                     label: Text(eachInvestigaion.name),
    //                     onDeleted: () {
    //                       update(
    //                         patient..investigations.remove(eachInvestigaion),
    //                       );
    //                     },
    //                     backgroundColor: Colors.deepOrange,
    //                   ),
    //                 )
    //                 .toList(),
    //           ),
    //           Text(
    //             'bills',
    //             textScaleFactor: 1.2,
    //           ),
    //           '${patient.investigations.fold(0, (i, s) => i + s.price)}'.text(),
    //           TextFormField(
    //             initialValue: patient.diagnosis,
    //             onChanged: (value) => update(
    //               patient.copyWith(diagnosis: value),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    throw '';
  }
}
