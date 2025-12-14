import 'package:hmis/domain/domain.dart';
import 'package:hmis/features/delete_er_mark.dart';
import 'package:hmis/features/er_case_register.dart';
import 'package:hmis/features/marksheet.dart';
import 'package:hmis/main.dart';

class Router extends ChangeNotifier {
  final router = GoRouter(
    routes: [
      addMarkDialogRoute,
      markSheetRoute,
      erCaseRegisterRoute,
      deleteErMarkDialogRoute,
    ],
  );

  void gotoAddMarkDialog(CaseType caseType, DutyShift dutyShift) {
    router.go(
      addMarkDialogRoute.path,
      extra: {
        'caseType': caseType,
        'dutyShift': dutyShift,
      },
    );
  }

  void goToMarkSheet() {
    router.go(markSheetRoute.path);
  }

  void goToErCaseRegister() {
    router.go(erCaseRegisterRoute.path);
  }

  void goToDeleteErMarkDialog(ErMark mark) {
    router.go(deleteErMarkDialogRoute.path, extra: mark);
  }
}

final addMarkDialogRoute = GoRoute(
  path: '/addMarkDialog',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    final caseType = extra['caseType'] as CaseType;
    final dutyShift = extra['dutyShift'] as DutyShift;

    return AddMarkDialog(
      caseType: caseType,
      shift: dutyShift,
    );
  },
);

final markSheetRoute = GoRoute(
  path: '/',
  builder: (context, state) => Marksheet(),
);

final erCaseRegisterRoute = GoRoute(
  path: '/erCaseRegister',
  builder: (context, state) => ErCaseRegisterPage(),
);

final deleteErMarkDialogRoute = GoRoute(
  path: '/deleteErMarkDialog',
  builder: (context, state) => DeleteErMarkDialog(
    mark: state.extra as ErMark,
  ),
);
