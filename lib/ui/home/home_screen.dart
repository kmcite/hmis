import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/configuration_cubit.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:hmis/ui/home/components/home_case_type_breakdown.dart';
import 'package:hmis/ui/home/components/home_context_header.dart';
import 'package:hmis/ui/home/components/home_pending_details.dart';
import 'package:hmis/ui/home/components/home_quick_actions.dart';
import 'package:hmis/ui/home/components/home_recent_patients.dart';
import 'package:hmis/ui/home/components/home_today_dashboard.dart';

/// ER front desk home: actions → KPI dashboard → case mix → recent activity.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ConfigurationCubit>().state.dark;
    return LiquidScaffold(
      appBar: LiquidAppBar(
        titleWidget: Text(
          'HMIS',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          LiquidIconButton(
            icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onPressed: () => context.read<ConfigurationCubit>().toggleDark(),
            tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
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
                  const SizedBox(height: 16),
                  const HomeContextHeader(),
                  const SizedBox(height: 20),
                  const HomeQuickActions(),
                  const SizedBox(height: 22),
                  const HomeTodayDashboard(),
                  const SizedBox(height: 28),
                  const HomePendingDetails(),
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
