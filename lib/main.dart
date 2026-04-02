export 'package:path/path.dart' show join;

import 'dart:io';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:forui/forui.dart';
import 'package:hmis/bussiness/investigations.dart';
import 'package:hmis/bussiness/logging.dart';
import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/bussiness/native_splash_removal.dart';
import 'package:hmis/bussiness/navigation.dart';
import 'package:hmis/bussiness/settings.dart';
import 'package:hmis/domain/services.dart';
import 'package:hmis/features/marksheet/marksheet.dart';
import 'package:hmis/objectbox.g.dart' show openStore;
import 'package:hmis/bussiness/business.dart';
import 'package:hmis/utils/redux.dart';
import 'package:redux/redux.dart' show Store;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaru/yaru.dart';

import 'main.dart';

export 'dart:convert';
export 'package:flex_color_scheme/flex_color_scheme.dart';
export 'package:flutter/material.dart' hide State, Router;
export 'package:flutter_native_splash/flutter_native_splash.dart';
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:freezed_annotation/freezed_annotation.dart';
export 'package:go_router/go_router.dart';
export 'package:hmis/features/home.dart';
export 'package:hmis/domain/investigation.dart';
export 'package:hmis/features/investigations.dart';
export 'package:objectbox/objectbox.dart' hide Store;
export 'package:hmis/domain/patient.dart';
export 'package:hmis/features/add_patient_dialog.dart';
export 'package:hmis/features/case_page.dart';
export 'package:hmis/features/patients_page.dart';
export 'package:hmis/features/settings_screen.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:path_provider/path_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

late Store<Business> store;

void main() async {
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  final appInfo = await PackageInfo.fromPlatform();
  final storageDirectory = Directory(
    join(
      (await getApplicationDocumentsDirectory()).path,
      appInfo.appName,
    ),
  );

  final storagePath = storageDirectory.path;
  objects = await openStore(directory: storagePath);
  preferences = await SharedPreferences.getInstance();

  runApp(
    StoreProvider(
      store: store = Store(
        BusinessReducer(),
        initialState: Business(),
        middleware: [
          LoggingMW(),
          Navigation(),
          NativeSplashRemovalMW(),
          MarksMW(),
          InvestigationsMW(),
          SettingsMW(),
        ],
      ),
      child: Application(),
    ),
  );
}

class Application extends UI {
  const Application({super.key});

  init() {
    dispatch(FlutterNativeSplashRemoved());
  }

  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      builder: (_, child) => FTheme(
        data: state.settings.dark ? FThemes.green.dark.touch : FThemes.green.light.touch,
        child: child!,
      ),
      theme: yaruLight,
      darkTheme: yaruDark,
      themeMode: state.settings.dark ? ThemeMode.dark : ThemeMode.light,
      home: Marksheet(),
    );
  }
}
