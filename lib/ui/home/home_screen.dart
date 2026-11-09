import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/business/sync_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/home/components/home_case_type_breakdown.dart';
import 'package:hmis/ui/home/components/home_context_header.dart';
import 'package:hmis/ui/home/components/home_quick_actions.dart';
import 'package:hmis/ui/home/components/home_recent_patients.dart';
import 'package:hmis/ui/home/components/home_today_dashboard.dart';
import 'package:hmis/ui/settings/settings_screen.dart';
import 'package:hmis/ui/shared/shell/connection_status_banner.dart';

/// ER front desk home: actions → KPI dashboard → case mix → recent activity.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<SyncCubit>().state.pendingOutbox;

    return LiquidScaffold(
      appBar: LiquidAppBar(
        title: 'HMIS',
        actions: [
          Badge(
            isLabelVisible: pending > 0,
            label: Text('$pending'),
            child: LiquidIconButton(
              icon: Icons.settings_outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              tooltip: pending > 0
                  ? 'Settings · $pending pending upload'
                  : 'Settings',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeCubit>().refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const ConnectionStatusBanner(),
                  const SizedBox(height: 16),
                  const HomeContextHeader(),
                  const SizedBox(height: 20),
                  const HomeQuickActions(),
                  const SizedBox(height: 22),
                  const HomeTodayDashboard(),
                  const SizedBox(height: 28),
                  const HomeCaseTypeBreakdown(),
                  const SizedBox(height: 28),
                  const HomeRecentPatients(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
