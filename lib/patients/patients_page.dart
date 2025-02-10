import 'package:hmis/main.dart';
import 'package:hmis/patients/patients_bloc.dart';

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});
  static const name = 'patients';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () {
            context.of<RouterBloc>().toRouteByName(HomePage.name);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: 'patients',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.of<RouterBloc>().toRouteByName(AddPatientPage.name),
        child: const Icon(Icons.add),
      ),
      body: context.of<PatientsBloc>().patients.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: const FaIcon(
                  FontAwesomeIcons.peopleGroup,
                  size: 150,
                ),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: context.of<PatientsBloc>().patients.map(
                (patient) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColorLight,
                        child: Text(
                          patient.age,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      onTap: () {
                        context.goNamed(PatientPage.name, extra: patient.id);
                      },
                      title: Text(
                        patient.name,
                        style: theme.textTheme.titleSmall,
                        textScaleFactor: 1.2,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
    );
  }
}
