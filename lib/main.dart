import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/objectbox.g.dart' show openStore;
import 'package:hmis/ui/chit/chit_notifier.dart';
import 'package:hmis/ui/er_case_register/er_case_register_filter.dart';
import 'package:hmis/ui/home/home_screen.dart';
import 'package:hmis/ui/home/settings.dart';
import 'package:hmis/ui/marksheet/er_mark.dart';
import 'package:hmis/ui/marksheet/er_mark_to_create.dart';
import 'package:hmis/ui/marksheet/er_mark_to_delete.dart';
import 'package:hmis/ui/marksheet/er_marks.dart';
import 'package:hmis/utils/of.dart';
import 'package:objectbox/objectbox.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart' hide MenuBar;
export 'package:hmis/models/models.dart';
export 'package:hmis/services/services.dart';
export 'package:path/path.dart' show join;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appInfo = await PackageInfo.fromPlatform();
  final storageDirectory = Directory(
    join(
      (await getApplicationDocumentsDirectory()).path,
      appInfo.appName,
    ),
  );

  final storagePath = storageDirectory.path;
  final objectboxService = await openStore(directory: storagePath);
  final preferencesService = await SharedPreferences.getInstance();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Store>.value(value: objectboxService),
        RepositoryProvider<SharedPreferences>.value(value: preferencesService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ErMarksBloc>(
            create: (context) => ErMarksBloc(context.read()),
          ),
          BlocProvider(
            create: (context) => ChitNotifier(context.read()),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(context.read()),
          ),
          BlocProvider<ErCaseRegisterFilterCubit>(
            create: (context) => ErCaseRegisterFilterCubit(),
          ),
          BlocProvider<ErMarkCubit>(
            create: (context) => ErMarkCubit(context.read()),
          ),
          BlocProvider<ErMarkToCreateCubit>(
            create: (context) => ErMarkToCreateCubit(context.read()),
          ),
          BlocProvider<ErMarkToDeleteCubit>(
            create: (context) => ErMarkToDeleteCubit(),
          ),
        ],
        child: const Application(),
      ),
    ),
  );
}

class Application extends StatelessWidget {
  const Application({super.key});
  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: .new(fontFamily: 'Google Sans'),
      darkTheme: .new(
        fontFamily: 'Google Sans',
        brightness: .dark,
      ),
      themeMode: context.of<SettingsCubit>().state.dark ? .dark : .light,
      home: const HomeScreen(),
    );
  }
}
