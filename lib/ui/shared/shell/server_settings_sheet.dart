import 'package:flutter/material.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/settings/components/sync_settings_panel.dart';

void showServerSettingsSheet(BuildContext context) {
  showLiquidSheet(
    context: context,
    child: const SyncSettingsPanel(compact: true),
  );
}
