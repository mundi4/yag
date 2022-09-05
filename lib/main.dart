import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:yag/src/home.dart';
import 'package:yag/src/models/login_model.dart';
import 'package:yag/src/models/settings_model.dart';
import 'package:yag/src/models/work_target_list_model.dart';
import 'package:yag/src/routes.dart';
import 'package:yag/src/settings.dart';

import 'src/atg.dart';
import 'src/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loginModel.loadFromStorage();
  await settingsModel.loadFromStorage();

  if (loginModel.username.isNotEmpty && loginModel.password.isNotEmpty) {
    try {
      await loginModel.login();
    } catch (error) {
      //log(error.toString());
    }
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: loginModel),
    ChangeNotifierProvider.value(value: settingsModel),
    ChangeNotifierProvider(create: (_) {
      final wtlm = WorkTargetListModel(atG: atg, settingsModel: settingsModel);
      wtlm.dueDate = DateUtils.dateOnly(DateTime.now().add(Duration(
          hours: settingsModel.workGroup == 'night'
              ? settingsModel.timeOffset
              : 0)));
      return wtlm;
    }),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var loginModel = context.read<LoginModel>();

    return MaterialApp(
      title: 'YAG',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ko', ''),
      supportedLocales: const [Locale('ko', '')],
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: loginModel.user == null ? loginRoute : homeRoute,
      routes: <String, WidgetBuilder>{
        homeRoute: (context) => const HomePage(),
        loginRoute: (context) => const LoginPage(),
        settingsRoute: (context) => const SettingsPage(),
      },
    );
  }
}
