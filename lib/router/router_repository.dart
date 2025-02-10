import 'package:hmis/main.dart';
import 'package:hmis/user_page.dart';

class RouterRepository {
  final router = GoRouter(
    routes: [
      GoRoute(
        name: HomePage.name,
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: InvestigationsPage.name,
            path: '/investigations_page',
            builder: (context, state) => const InvestigationsPage(),
          ),
          GoRoute(
            name: PatientsPage.name,
            path: '/patients_page',
            builder: (context, state) => const PatientsPage(),
            routes: [
              GoRoute(
                name: AddPatientPage.name,
                path: '/add_patients_page',
                pageBuilder: (_, __) =>
                    NoTransitionPage(child: AddPatientPage()),
              ),
              GoRoute(
                name: PatientPage.name,
                path: '/patient_page',
                builder: (context, state) =>
                    PatientPage(id: state.extra as int),
              ),
            ],
          ),
          GoRoute(
            name: SettingsPage.name,
            path: '/settings_page',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            name: UserPage.name,
            path: '/user_page',
            builder: (context, state) => const UserPage(),
          ),
        ],
      ),
    ],
  );

  void toRouteByName(String name) {
    router.goNamed(name);
  }

  void toRouteByPath(String path) {
    router.go(path);
  }
}
