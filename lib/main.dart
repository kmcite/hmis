export 'package:path/path.dart' show join;

import 'dart:io';

// import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:hmis/domain/domain.dart';
import 'package:hmis/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'package:hmis/utils/locator.dart';

import 'main.dart';

export 'dart:convert';
export 'package:flex_color_scheme/flex_color_scheme.dart';
export 'package:flutter/material.dart' hide State, Router;
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:flutter_native_splash/flutter_native_splash.dart';
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:freezed_annotation/freezed_annotation.dart';
export 'package:go_router/go_router.dart';
export 'package:hmis/custom_app_bar.dart';
export 'package:hmis/home/home_page.dart';
export 'package:hmis/investigations/investigations.dart';
export 'package:hmis/investigations/investigations_page.dart';
export 'package:hmis/objectbox.g.dart';
export 'package:objectbox/objectbox.dart';
export 'package:hmis/patients/patients.dart';
export 'package:hmis/patients/add_patient_dialog.dart';
export 'package:hmis/patients/patient_page.dart';
export 'package:hmis/patients/patients_page.dart';
export 'package:hmis/settings/settings_repository.dart';
export 'package:hmis/settings/settings_page.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:path_provider/path_provider.dart';

late Store store;
late SharedPreferences preferences;

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
  store = await openStore(directory: storagePath);
  preferences = await SharedPreferences.getInstance();

  put(ErRegisterRepository());
  put(Router());
  runApp(Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: find<Router>().router,
    );
  }
}
