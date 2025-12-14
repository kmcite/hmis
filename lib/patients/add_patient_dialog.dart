import '../main.dart';

class AddPatientPage extends StatelessWidget {
  AddPatientPage({super.key});

  static const name = '/add_patient_dialog';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final nameRM = TextEditingController();
    final ageRM = TextEditingController(text: '20');

    return AlertDialog(
      title: const Text('add patient'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'name',
              ),
              controller: nameRM,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: ageRM,
              autovalidateMode: AutovalidateMode.always,
              decoration: const InputDecoration(
                labelText: 'age',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return 'please enter a valid age';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // if (_formKey.currentState!.validate()) {
            //   final patient = Patient()
            //     ..name = nameRM.text
            //     ..age = ageRM.text;
            //   context
            //     ..of<PatientsBloc>().put(patient)
            //     ..pop();
            // }
          },
          child: const Text('save'),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('cancel'),
        ),
      ],
    );
  }
}
