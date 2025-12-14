import 'package:hmis/main.dart';

class InvestigationsPage extends StatefulWidget {
  static const name = 'investigations';

  const InvestigationsPage({super.key});

  @override
  State<InvestigationsPage> createState() => _InvestigationsPageState();
}

class _InvestigationsPageState extends State<InvestigationsPage> {
  bool editing = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'investigations',
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              setState(() {
                editing = !editing;
              });
            },
            icon: Icon(editing ? Icons.done : Icons.edit),
          ),
          SizedBox(width: 8)
        ],
      ),
      // body: ListView.builder(
      //   // itemCount: context.of<InvestigationsBloc>().investigations.length,
      //   itemBuilder: (context, index) {
      //     final investigation =
      //         context.of<InvestigationsBloc>().investigations.elementAt(index);
      //     return ListTile(
      //       key: Key(investigation.id.toString()),
      //       title: editing
      //           ? TextFormField(
      //               initialValue: investigation.name,
      //               onChanged: (value) {
      //                 // context
      //                 //   .of<InvestigationsBloc>()
      //                 //   .put(investigation..name = value);
      //               },
      //             )
      //           : Text(investigation.name),
      //       trailing: editing
      //           ? IconButton(
      //               onPressed: () {
      //                 // context.of<InvestigationsBloc>().remove(investigation.id);
      //               },
      //               icon: const Icon(Icons.delete),
      //             )
      //           : null,
      //     );
      //   },
      // ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton(
            onPressed: () {
              // context.of<InvestigationsBloc>().put(
              //       Investigation(),
              //     );
            },
            child: Text('Add New Investigation'),
          ),
        ],
      ),
    );
  }
}
