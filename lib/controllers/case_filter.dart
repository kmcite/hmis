import 'package:hmis/utils/router.dart';

final caseFilterController = provider((f) => CaseFilter());

enum CaseRegisterFilter { casesByDay, allCases }

class CaseFilter {
  final filter = signal(
    CaseRegisterFilter.casesByDay,
    name: 'case_filter.filter',
  );

  /// Server-side total for the "all cases" view, not the number of rows
  /// paged in so far. Null until the first page lands.
  final total = signal<int?>(null, name: 'case_filter.total');

  void setFilter(CaseRegisterFilter f) => filter.value = f;

  void toggle() => filter.value = filter.peek() == CaseRegisterFilter.casesByDay
      ? CaseRegisterFilter.allCases
      : CaseRegisterFilter.casesByDay;
}
