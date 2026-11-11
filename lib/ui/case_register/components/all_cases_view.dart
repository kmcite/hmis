import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/case_register_cubit.dart';
import 'package:hmis/ui/case_register/components/case_register_empty_view.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/case_register/components/patient_tile.dart';

class AllCasesView extends StatefulWidget {
  const AllCasesView({super.key});

  @override
  State<AllCasesView> createState() => _AllCasesViewState();
}

class _AllCasesViewState extends State<AllCasesView> {
  var _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      context.read<CaseRegisterCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final register = context.watch<CaseRegisterCubit>().state;

    if (register.loadingMore && register.patients.isEmpty) {
      return const LiquidProgress(message: 'Loading register…');
    }

    if (register.patients.isEmpty) {
      return const EmptyView();
    }

    final cubit = context.read<CaseRegisterCubit>();

    return NotificationListener<ScrollEndNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 200) cubit.loadMore();
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: register.patients.length + (register.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= register.patients.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LiquidProgress(compact: true),
            );
          }
          return PatientTile(register.patients[index]);
        },
      ),
    );
  }
}
