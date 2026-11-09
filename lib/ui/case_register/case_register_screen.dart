import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/case_filter_cubit.dart';
import 'package:hmis/business/new_chit_cubit.dart';
import 'package:hmis/business/sheet_cubit.dart';
import 'package:hmis/ui/new_chit/new_chit_screen.dart';
import 'package:hmis/ui/case_register/components/day_cases_view.dart';
import 'package:hmis/ui/case_register/components/toggle_filter_button.dart';
import 'package:hmis/ui/case_register/components/all_cases_view.dart';
import 'package:hmis/ui/marksheet/components/datebar.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:intl/intl.dart';

class CaseRegisterScreen extends StatelessWidget {
  const CaseRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseFilter = context.watch<CaseFilterCubit>().state;
    final sheet = context.watch<SheetCubit>().state;
    final filter = caseFilter.filter;
    final byDay = filter == CaseRegisterFilter.casesByDay;

    final title = byDay
        ? 'Sheet ${DateFormat('d MMM').format(sheet.selectedDay)}'
        : 'All cases';

    return LiquidScaffold(
      appBar: LiquidAppBar(
        title: title,
        actions: const [
          CaseFilterButton(),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: LiquidFab(
        extended: true,
        icon: Icons.add_rounded,
        label: 'New case',
        onPressed: () {
          context.read<NewChitCubit>().init();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewChitScreen()),
          );
        },
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
