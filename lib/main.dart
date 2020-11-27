import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_create/generated/i18n.dart';
import 'package:flutter_create/model/model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screen/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AfterLayoutMixin {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void afterFirstLayout(BuildContext context) {
    final appContext = _navigatorKey.currentContext;
    final locale = Localizations.localeOf(appContext);
    if (locale.languageCode == 'ru') {
      appContext.read<FilmsModel>().setLang('ru-RU');
    } else {
      appContext.read<FilmsModel>().setLang('en-US');
    }
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => FilmsModel()..loadMovies(),
            lazy: false,
          )
        ],
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Filmest',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            backgroundColor: Colors.grey.shade600,
          ),
          home: MainPage(),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          localeResolutionCallback: S.delegate.resolution(
            fallback: const Locale('en', ''),
          ),
        ),
      );
}
