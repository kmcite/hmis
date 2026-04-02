import 'package:hmis/bussiness/navigation.dart';
import 'package:hmis/main.dart';
import 'package:hmis/bussiness/investigations.dart';
import 'package:hmis/utils/redux.dart';

class Investigations extends UI {
  const Investigations({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investigations'),
      ),
      body: ListView.builder(
        itemCount: state.investigations.all.length,
        itemBuilder: (context, i) {
          final inv = state.investigations.all[i];
          return InvestigationTile(inv);
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                dispatch(
                  ShowDialog(AddInvestigationDialog()),
                );
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class AddInvestigationDialog extends UI {
  @override
  void init() {
    dispatch(CreateNewInvestigationStarted());
  }

  @override
  void dispose() {
    dispatch(CreateNewInvestigationStopped());
  }

  @override
  Widget build(BuildContext) {
    return SimpleDialog(
      title: Text('Add New Investigation'),
      contentPadding: EdgeInsets.all(8),
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'NAME'),
          initialValue: state.investigations.newInvestigation!.name,
          onChanged: (value) {
            dispatch(NameChanged(value));
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('PRICE ${state.investigations.newInvestigation!.price}'),
        ),
        Slider(
          value: state.investigations.newInvestigation!.price.toDouble(),
          onChanged: (value) {
            dispatch(PriceChanged(value.round()));
          },
          min: 0,
          max: 5000,
          divisions: 100,
        ),
        FilledButton(
          onPressed: () {
            dispatch(
              AddInvestigationAction(),
            );
            dispatch(NavigateBack());
          },
          child: Icon(Icons.save),
        ),
      ],
    );
  }
}

class InvestigationTile extends StatelessWidget {
  final Investigation investigation;

  const InvestigationTile(this.investigation, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('id:${investigation.id} name: ' + investigation.name),
      subtitle: Text(investigation.price.toString()),
      onTap: () {
        dispatch(
          NavigateTo(
            Scaffold(
              appBar: AppBar(),
              body: Column(
                children: [],
              ),
            ),
          ),
        );
      },
    );
  }
}
