import 'package:hmis/main.dart';
import 'package:hmis/settings/hospital_repository.dart';

class HomePage extends StatelessWidget {
  static const name = 'home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: const SizedBox(),
        title: 'HMIS',
      ),
      body: Stack(
        children: [
          const Opacity(
            opacity: .3,
            child: Align(
              child: FaIcon(
                FontAwesomeIcons.hospital,
                size: 150,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Align(
              child: Text(context.of<HospitalBloc>().name),
            ),
          ),
          Opacity(
            opacity: .9,
            child: ListView(
              children: [
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(
                      FontAwesomeIcons.hospital,
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          '${context.of<HospitalBloc>().name}'.text(),
                          '${context.of<HospitalBloc>().city}'.text(),
                          '${context.of<HospitalBloc>().info}'.text(),
                        ],
                      ),
                    ).pad(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton.icon(
                    onPressed: () => context
                        .of<RouterBloc>()
                        .toRouteByName(PatientsPage.name),
                    icon: const Icon(FontAwesomeIcons.route),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: 'patients'.text(),
                    ).pad(),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context
                      .of<RouterBloc>()
                      .toRouteByName(InvestigationsPage.name),
                  icon: const Icon(FontAwesomeIcons.fileInvoice),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: 'investigations'.text(),
                    ),
                  ),
                ).pad(),
                FilledButton.icon(
                  onPressed: () {
                    context.of<RouterBloc>().toRouteByName('settings');
                  },
                  icon: const Icon(FontAwesomeIcons.confluence),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('settings'),
                    ),
                  ),
                ).pad(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
