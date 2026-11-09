import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/sync_connection_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final degraded = context.watch<SyncConnectionCubit>().state.linkUnstable;
    if (!degraded) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return LiquidBanner(
      icon: Icons.sync_rounded,
      tint: cs.tertiary,
      message: 'Connection unstable — retrying sync…',
      margin: const EdgeInsets.only(bottom: 4),
      action: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: cs.tertiary),
      ),
    );
  }
}
