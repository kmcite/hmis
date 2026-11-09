import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/case_filter_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';

class CaseFilterButton extends StatelessWidget {
  const CaseFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final caseFilter = context.watch<CaseFilterCubit>().state;
    final byDay = caseFilter.filter == CaseRegisterFilter.casesByDay;
    return LiquidIconButton(
      onPressed: () => context.read<CaseFilterCubit>().toggle(),
      icon: byDay ? Icons.calendar_today : Icons.view_list_rounded,
      tooltip: byDay ? 'Show all cases' : 'Show by day',
    );
  }
}
