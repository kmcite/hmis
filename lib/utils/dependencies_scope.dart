import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hmis/business/case_filter_cubit.dart';
import 'package:hmis/business/case_register_cubit.dart';
import 'package:hmis/business/configuration_cubit.dart';
import 'package:hmis/business/er_mark_draft_cubit.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/business/new_chit_cubit.dart';
import 'package:hmis/business/sync_connection_cubit.dart';
import 'package:hmis/business/sheet_cubit.dart';
import 'package:hmis/business/sync_cubit.dart';
import 'package:hmis/domain/repositories/hmis_local_store.dart';
import 'package:hmis/domain/repositories/marks_repository.dart';
import 'package:hmis/domain/repositories/sync_repository.dart';
import 'package:hmis/services/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root — wires layers top-down:
///
/// **services** → **domain** → **business** (cubits) → **ui** (screens).
///
/// Data flows: UI event → cubit → repository → local/sync → cubit state → UI.
class DependenciesScope extends StatelessWidget {
  const DependenciesScope({
    super.key,
    required this.localStore,
    required this.child,
  });

  final HmisLocalStore localStore;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HmisLocalStore>.value(value: localStore),
        RepositoryProvider<PocketBaseService>(
          create: (_) => PocketBaseService(),
          dispose: (service) => service.dispose(),
        ),
        RepositoryProvider<MarksRepository>(
          create: (_) => MarksRepository(localStore),
          dispose: (repo) => repo.dispose(),
        ),
        RepositoryProvider<SyncRepository>(
          create: (c) => SyncRepository(
            localStore,
            c.read<MarksRepository>(),
          ),
          dispose: (sync) => sync.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                ConfigurationCubit(SharedPreferencesAsync())..initialize(),
          ),
          BlocProvider(
            create: (c) => SyncCubit(
              c.read<SyncRepository>(),
              c.read<PocketBaseService>(),
              c.read<MarksRepository>(),
            ),
          ),
          BlocProvider(create: (_) => CaseFilterCubit()),
          BlocProvider(
            create: (c) => SheetCubit(c.read<MarksRepository>())..initialize(),
          ),
          BlocProvider(
            create: (c) => HomeCubit(c.read<MarksRepository>())..initialize(),
          ),
          BlocProvider(
            create: (c) => ErMarkDraftCubit(c.read<MarksRepository>()),
          ),
          BlocProvider(
            create: (c) => NewChitCubit(c.read<MarksRepository>()),
          ),
          BlocProvider(
            create: (c) => CaseRegisterCubit(c.read<MarksRepository>()),
          ),
          BlocProvider(
            create: (c) => SyncConnectionCubit(
              c.read<PocketBaseService>(),
              c.read<SyncCubit>(),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
