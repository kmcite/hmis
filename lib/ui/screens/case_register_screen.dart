import 'package:flutter/material.dart';
import 'package:hmis/controllers/case_filter.dart';
import 'package:hmis/controllers/sheet.dart';
import 'package:hmis/ui/er_case_register/body/day_cases_view.dart';
import 'package:hmis/ui/er_case_register/toggle_filter_button.dart';
import 'package:hmis/ui/er_case_register/body/all_cases_view.dart';
import 'package:hmis/ui/marksheet/datebar.dart';
import 'package:intl/intl.dart';
import 'package:hmis/utils/router.dart';

class CaseRegisterScreen extends SignalConsumer {
  const CaseRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseFilter = caseFilterController(context);
    final sheet = sheetController(context);
    final filter = caseFilter.filter();
    final byDay = filter == CaseRegisterFilter.casesByDay;

    final title = byDay
        ? 'Shift — ${DateFormat('d MMM').format(sheet.selectedDay())}'
        // Null while the first page is in flight — bare 'All Cases'
        // reads better than 'All Cases (0)'.
        : 'All Cases${caseFilter.total() == null ? '' : ' (${caseFilter.total()})'}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [
          CaseFilterButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (byDay) const DateBar(),
            Expanded(
              child: byDay ? const DayCasesView() : AllCasesView(),
            ),
          ],
        ),
      ),
    );
  }
}
