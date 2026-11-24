import 'dart:async';
import 'tienda/idioma.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';

// El marco de teléfono de la vista web puede cubrir el encabezado sin
// comunicar un margen superior. En un dispositivo se respeta el margen real.
Widget protegerEncabezadoMovil(BuildContext context, Widget? child) {
  final pantalla = MediaQuery.of(context);
  if (!kIsWeb ||
      Uri.base.host != 'tm-prod.dreamflow.cloud' ||
      pantalla.size.width >= 600 ||
      pantalla.orientation != Orientation.portrait ||
      pantalla.viewPadding.top > 0) {
    return child ?? const SizedBox.shrink();
  }
  const margenSuperior = 52.0;
  return MediaQuery(
    data: pantalla.copyWith(
      padding: pantalla.padding.copyWith(top: margenSuperior),
      viewPadding: pantalla.viewPadding.copyWith(top: margenSuperior),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  await FlutterFlowTheme.initialize();
  await cargarIdioma();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late final StreamSubscription<BaseAuthUser> _userSub;
  late final StreamSubscription _tokenSub;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    _userSub = perfumesSalazarFirebaseUserStream().listen((user) {
      _appStateNotifier.update(user);
    });
    _tokenSub = jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();
    _userSub.cancel();
    _tokenSub.cancel();

    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
        valueListenable: idiomaApp,
        builder: (_, idioma, __) => MaterialApp.router(
              locale: idioma,
              debugShowCheckedModeBanner: false,
              builder: protegerEncabezadoMovil,
              title: 'Perfumes Salazar',
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('es', 'CR'), Locale('en')],
              theme: ThemeData(
                colorScheme:
                    ColorScheme.fromSeed(seedColor: const Color(0xff926c32)),
                scaffoldBackgroundColor: const Color(0xfff9f4e9),
                inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white),
                appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xff211b17),
                    foregroundColor: Colors.white),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: false,
              ),
              themeMode: _themeMode,
              routerConfig: _router,
            ));
  }
}
