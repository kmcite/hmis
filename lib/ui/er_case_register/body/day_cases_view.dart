import 'package:flutter/material.dart';
import 'package:hmis/controllers/sheet.dart';
import 'package:hmis/ui/er_case_register/body/case_register_empty_view.dart';
import 'package:hmis/ui/er_case_register/body/er_mark_tile.dart';
import 'package:hmis/utils/router.dart';

class DayCasesView extends SignalConsumer {
  const DayCasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final sheet = sheetController(context);
    if (sheet.loading()) return const Center(child: CircularProgressIndicator());
    if (sheet.error() != null) return const EmptyView();

    final data = sheet.marks();
    if (data.isEmpty) return const EmptyView();

    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) => ErMarkTile(data[index]),
    );
  }
}
