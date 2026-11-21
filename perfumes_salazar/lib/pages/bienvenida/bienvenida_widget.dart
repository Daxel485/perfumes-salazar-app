import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/tienda/idioma.dart';
import 'package:flutter/material.dart';
import 'bienvenida_model.dart';
export 'bienvenida_model.dart';

class BienvenidaWidget extends StatefulWidget {
  const BienvenidaWidget({super.key});

  static String routeName = 'Bienvenida';
  static String routePath = '/bienvenida';

  @override
  State<BienvenidaWidget> createState() => _BienvenidaWidgetState();
}

class _BienvenidaWidgetState extends State<BienvenidaWidget> {
  late BienvenidaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BienvenidaModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xff201c19),
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xffb89152))),
                      child: const Icon(Icons.filter_vintage_outlined,
                          color: Color(0xffd8bc8e), size: 46)),
                  const SizedBox(height: 28),
                  const Text('PERFUMES',
                      style: TextStyle(
                          letterSpacing: 5,
                          fontSize: 13,
                          color: Color(0xffd8bc8e))),
                  const Text('SALAZAR',
                      style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 52,
                          letterSpacing: 4,
                          color: Color(0xfffaf4e8))),
                  const SizedBox(height: 16),
                  Text(
                      traducir(context,
                          'Descubre fragancias exclusivas diseñadas para cautivar tus sentidos.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, height: 1.5, color: Color(0xffe6d9c6))),
                  const SizedBox(height: 36),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xffd7b574),
                              foregroundColor: const Color(0xff211b17),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 17)),
                          onPressed: () =>
                              context.pushNamed(IniciarSesionWidget.routeName),
                          child: const Etiqueta('Iniciar sesión'))),
                  const SizedBox(height: 10),
                  SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xffbd9e66)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 17)),
                          onPressed: () =>
                              context.pushNamed(RegistroWidget.routeName),
                          child: const Etiqueta('Crear cuenta'))),
                  const SizedBox(height: 10),
                  TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xffe3cba4)),
                      onPressed: () => context.goNamed(InicioWidget.routeName),
                      child: const Etiqueta('Explorar como invitado')),
                ],
              )),
        ))),
      );
}
