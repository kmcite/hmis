import 'package:flutter/material.dart';
import 'package:hmis/controllers/case_register.dart';
import 'package:hmis/ui/er_case_register/body/case_register_empty_view.dart';
import 'package:hmis/ui/er_case_register/body/er_mark_tile.dart';
import 'package:hmis/utils/router.dart';

class AllCasesView extends SignalConsumer {
  const AllCasesView({super.key});

  @override
  void init(BuildContext context) => caseRegisterController(context).loadMore();

  @override
  Widget build(BuildContext context) {
    final register = caseRegisterController(context);
    final marks = register.marks();
    if (marks.isEmpty) return const EmptyView();

    return NotificationListener<ScrollEndNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 200) register.loadMore();
        return false;
      },
      child: ListView.builder(
        itemCount: marks.length,
        itemBuilder: (context, index) => ErMarkTile(marks[index]),
      ),
    );
  }
}
