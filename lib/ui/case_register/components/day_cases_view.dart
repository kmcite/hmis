import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/sheet_cubit.dart';
import 'package:hmis/ui/case_register/components/case_register_empty_view.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/case_register/components/er_mark_tile.dart';

class DayCasesView extends StatelessWidget {
  const DayCasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final sheet = context.watch<SheetCubit>().state;
    if (sheet.loading) {
      return const LiquidProgress(message: 'Loading cases…');
    }
    if (sheet.error != null) return const EmptyView();

    final data = sheet.marks;
    if (data.isEmpty) return const EmptyView();

    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: data.length,
      itemBuilder: (context, index) => ErMarkTile(data[index]),
    );
  }
}
