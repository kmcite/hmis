import 'package:flutter/material.dart';
import 'package:hmis/controllers/case_filter.dart';
import 'package:hmis/utils/router.dart';

class CaseFilterButton extends SignalConsumer {
  const CaseFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final caseFilter = caseFilterController(context);
    final byDay = caseFilter.filter() == CaseRegisterFilter.casesByDay;
    return IconButton(
      onPressed: caseFilter.toggle,
      icon: Icon(byDay ? Icons.calendar_today : Icons.list),
      tooltip: byDay ? 'Show all cases' : 'Show by day',
    );
  }
}
