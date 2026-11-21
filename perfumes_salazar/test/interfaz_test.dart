import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perfumes_salazar/pages/bienvenida/bienvenida_widget.dart';
import 'package:perfumes_salazar/tienda/idioma.dart';

void main() {
  testWidgets(
      'Bienvenida desplazable en 320 × 480 y acceso al catálogo como invitado',
      (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const BienvenidaWidget()),
      GoRoute(
          path: '/inicio',
          name: 'Inicio',
          builder: (_, __) => const Scaffold(body: Text('Catálogo de prueba'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
        locale: const Locale('es', 'CR'),
        supportedLocales: const [Locale('es', 'CR'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final invitado = find.text('Explorar como invitado');
    await tester.ensureVisible(invitado);
    await tester.tap(invitado);
    await tester.pumpAndSettle();
    expect(find.text('Catálogo de prueba'), findsOneWidget);
  });
  testWidgets('La preferencia de idioma se restaura y traduce los controles',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await cambiarIdioma('en');
    idiomaApp.value = const Locale('es', 'CR');
    await cargarIdioma();
    expect(idiomaApp.value.languageCode, 'en');
    await tester.pumpWidget(MaterialApp(
        locale: idiomaApp.value,
        home: const Scaffold(body: Etiqueta('Confirmar pedido'))));
    expect(find.text('Confirm order'), findsOneWidget);
    await cambiarIdioma('es');
  });
}
