import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/configuration_cubit.dart';
import 'package:hmis/business/sync_connection_cubit.dart';
import 'package:hmis/business/sync_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/settings/components/sync_settings_panel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigurationCubit>().state;
    final conn = context.watch<SyncConnectionCubit>().state;
    final pending = context.watch<SyncCubit>().state.pendingOutbox;
    final cs = Theme.of(context).colorScheme;

    return LiquidScaffold(
      appBar: LiquidAppBar(
        title: 'Settings',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const LiquidSectionLabel('Appearance'),
          const SizedBox(height: 10),
          LiquidCard(
            specular: false,
            padding: EdgeInsets.zero,
            child: LiquidListTile(
              title: const Text('Dark mode'),
              subtitle: Text(
                config.dark ? 'On — easier at night' : 'Off — light canvas',
              ),
              leading: Icon(
                config.dark ? Icons.dark_mode : Icons.light_mode_outlined,
                size: 22,
              ),
              trailing: Switch.adaptive(
                value: config.dark,
                onChanged: (v) =>
                    context.read<ConfigurationCubit>().setDark(v),
              ),
              variant: LiquidVariant.surface,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: LiquidSectionLabel('Sync & backup')),
              if (pending > 0)
                LiquidChip(
                  label: '$pending queued',
                  icon: Icons.cloud_upload_outlined,
                  tint: cs.tertiary,
                  dense: true,
                ),
            ],
          ),
          const SizedBox(height: 10),
          LiquidCard(
            child: SyncSettingsPanel(),
          ),
          const SizedBox(height: 16),
          LiquidBanner(
            tint: cs.primary,
            icon: conn.isConnected
                ? Icons.cloud_done_outlined
                : Icons.storage_outlined,
            message: conn.isConnected
                ? 'Live sync with PocketBase'
                : conn.syncEnabled
                    ? 'Sync enabled — not connected'
                    : 'All data stored locally on this device',
          ),
        ],
      ),
    );
  }
}
