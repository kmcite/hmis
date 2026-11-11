import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/configuration_cubit.dart';
import 'package:hmis/utils/dependencies_scope.dart';
import 'package:hmis/ui/home/home_screen.dart';
import 'package:hmis/ui/shared/theme/hmis_theme.dart';
import 'package:hmis/ui/shared/liquid/liquid.dart';
import 'package:shared_database/shared_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await SharedDatabase.open();
  runApp(
    DependenciesScope(
      database: database,
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
