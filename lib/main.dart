import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/configuration_cubit.dart';
import 'package:hmis/domain/repositories/hmis_local_store.dart';
import 'package:hmis/utils/dependencies_scope.dart';
import 'package:hmis/ui/home/home_screen.dart';
import 'package:hmis/ui/shared/theme/hmis_theme.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStore = await HmisLocalStore.open();
  runApp(
    DependenciesScope(
      localStore: localStore,
      child: const Application(),
    ),
  );
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigurationCubit, ConfigurationState>(
      builder: (context, config) {
        return MaterialApp(
          title: 'HMIS',
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
          theme: HmisTheme.light(),
          darkTheme: HmisTheme.dark(),
          themeMode: config.themeMode,
          builder: (context, child) => LiquidCanvas(child: child!),
        );
      },
    );
  }
}
