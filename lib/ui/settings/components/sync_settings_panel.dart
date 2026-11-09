import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/sync_connection_cubit.dart';
import 'package:hmis/business/sync_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';

/// PocketBase sync controls (embedded in settings or bottom sheet).
class SyncSettingsPanel extends StatefulWidget {
  const SyncSettingsPanel({super.key, this.compact = false});

  final bool compact;

  @override
  State<SyncSettingsPanel> createState() => _SyncSettingsPanelState();
}

class _SyncSettingsPanelState extends State<SyncSettingsPanel> {
  final _adminEmail = TextEditingController();
  final _adminPassword = TextEditingController();
  TextEditingController? _host;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _host ??= TextEditingController(
      text: context.read<SyncConnectionCubit>().state.hostInput,
    );
  }

  @override
  void dispose() {
    _adminEmail.dispose();
    _adminPassword.dispose();
    _host?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<SyncConnectionCubit>().state;
    final sync = context.watch<SyncCubit>().state;
    final connCubit = context.read<SyncConnectionCubit>();
    final syncCubit = context.read<SyncCubit>();
    final cs = Theme.of(context).colorScheme;

    final connected = conn.syncEnabled && conn.isConnected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.compact) ...[
          Text(
            'Cloud sync',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          connected
              ? 'Connected — changes upload in the background.'
              : conn.syncEnabled
                  ? 'Sync is on; waiting for a live connection.'
                  : 'Marks stay on this device until you enable sync.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        LiquidListTile(
          title: const Text('Enable sync'),
          subtitle: Text(
            conn.syncEnabled ? 'PocketBase' : 'Local only',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Switch.adaptive(
            value: conn.syncEnabled,
            onChanged: connCubit.setSyncEnabled,
          ),
          variant: LiquidVariant.inset,
        ),
        if (sync.pendingOutbox > 0) ...[
          const SizedBox(height: 10),
          LiquidBanner(
            tint: cs.tertiary,
            icon: Icons.cloud_upload_outlined,
            message: '${sync.pendingOutbox} change(s) queued',
          ),
        ],
        if (conn.syncEnabled) ...[
          const SizedBox(height: 12),
          LiquidTextField(
            key: const ValueKey('pb-host'),
            controller: _host,
            label: 'PocketBase host',
            prefixIcon: Icons.dns_outlined,
            readOnly: conn.isConnecting,
            enabled: !conn.isConnecting,
            onChanged: connCubit.setHostInput,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          if (!widget.compact) ...[
            const SizedBox(height: 16),
            const LiquidSectionLabel(
              'First-time server setup',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              'Superuser credentials provision the marks collection. '
              'They are not stored on this device.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          LiquidTextField(
            controller: _adminEmail,
            label: 'Admin email',
            prefixIcon: Icons.admin_panel_settings_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
          ),
          const SizedBox(height: 8),
          LiquidTextField(
            controller: _adminPassword,
            label: 'Admin password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            enableSuggestions: false,
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          LiquidButton(
            onPressed: conn.isConnecting
                ? null
                : () => connCubit.provisionAndConnect(
                      adminEmail: _adminEmail.text.trim(),
                      adminPassword: _adminPassword.text,
                    ),
            expand: true,
            child: Text(conn.isConnecting ? 'Working…' : 'Provision & connect'),
          ),
          const SizedBox(height: 8),
          LiquidButton(
            onPressed: conn.canConnect ? () => connCubit.connect() : null,
            style: LiquidButtonStyle.secondary,
            expand: true,
            child: const Text('Connect (provisioned)'),
          ),
          if (conn.isConnected) ...[
            const SizedBox(height: 8),
            LiquidButton(
              onPressed: () => connCubit.disconnect(),
              style: LiquidButtonStyle.plain,
              expand: true,
              child: const Text('Disconnect'),
            ),
            const SizedBox(height: 8),
            LiquidButton(
              onPressed: sync.syncing ? null : () => syncCubit.syncNow(),
              style: LiquidButtonStyle.secondary,
              expand: true,
              child: Text(sync.syncing ? 'Syncing…' : 'Sync now'),
            ),
          ],
          if (conn.errorMessage != null) ...[
            const SizedBox(height: 12),
            LiquidBanner(
              tint: cs.error,
              icon: Icons.error_outline,
              message: conn.errorMessage!,
            ),
          ],
        ],
      ],
    );
  }
}
