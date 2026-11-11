import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hmis/business/case_filter_cubit.dart';
import 'package:hmis/business/case_register_cubit.dart';
import 'package:hmis/business/configuration_cubit.dart';
import 'package:hmis/business/patient_draft_cubit.dart';
import 'package:hmis/business/home_cubit.dart';
import 'package:hmis/business/new_chit_cubit.dart';
import 'package:hmis/business/sheet_cubit.dart';
import 'package:hmis/domain/repositories/app_settings_store.dart';
import 'package:hmis/domain/repositories/patients_repository.dart';
import 'package:shared_database/shared_database.dart';

/// Composition root — wires layers top-down:
///
/// **services** → **domain** → **business** (cubits) → **ui** (screens).
///
/// Data flows: UI event → cubit → repository → shared database → cubit state → UI.
class DependenciesScope extends StatelessWidget {
  const DependenciesScope({
    super.key,
    required this.database,
    required this.child,
  });

  final SharedDatabase database;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedDatabase>.value(value: database),
        RepositoryProvider<AppSettingsStore>(
          create: (_) => AppSettingsStore(database),
        ),
        RepositoryProvider<PatientsRepository>(
          create: (_) => PatientsRepository(database),
          dispose: (repo) => repo.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) =>
                ConfigurationCubit(c.read<AppSettingsStore>())..initialize(),
          ),
          BlocProvider(create: (_) => CaseFilterCubit()),
          BlocProvider(
            create: (c) => SheetCubit(c.read<PatientsRepository>())..initialize(),
          ),
          BlocProvider(
            create: (c) => HomeCubit(c.read<PatientsRepository>())..initialize(),
          ),
          BlocProvider(
            create: (c) => PatientDraftCubit(c.read<PatientsRepository>()),
          ),
          BlocProvider(
            create: (c) => NewChitCubit(c.read<PatientsRepository>()),
          ),
          BlocProvider(
            create: (c) => CaseRegisterCubit(c.read<PatientsRepository>()),
          ),
        ],
        child: child,
      ),
    );
  }
}
