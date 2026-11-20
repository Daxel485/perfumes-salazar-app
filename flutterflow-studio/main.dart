import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '/backend/backend.dart' show maybeCreateUser;
import 'index.dart';

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
    _router = crearRutasTienda(_appStateNotifier);
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

typedef Datos = Map<String, dynamic>;
typedef Ficha = QueryDocumentSnapshot<Datos>;
final _salazarDb = FirebaseFirestore.instance;
User? get cliente => FirebaseAuth.instance.currentUser;
DocumentReference<Datos> get perfil => _salazarDb.collection('users').doc(cliente!.uid);
int entero(dynamic valor) => valor is num ? valor.toInt() : 0;
const tinta = Color(0xff211b17);
const crema = Color(0xfff9f4e9);
const oro = Color(0xffbe9147);

class Resultados extends StatefulWidget {
  const Resultados(this.consulta, this.construir, {super.key});
  final Query<Datos> consulta;
  final Widget Function(List<Ficha>) construir;
  @override
  State<Resultados> createState() => _ResultadosState();
}

class _ResultadosState extends State<Resultados> {
  late Stream<QuerySnapshot<Datos>> datos;
  @override
  void initState() {
    super.initState();
    datos = widget.consulta.snapshots();
  }

  @override
  void didUpdateWidget(Resultados old) {
    super.didUpdateWidget(old);
    if (old.consulta != widget.consulta) datos = widget.consulta.snapshots();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Datos>>(
        stream: datos,
        builder: (_, snap) {
          if (snap.hasError)
            return const Center(
              child: Etiqueta(
                'No se pudieron consultar los datos. Comprueba tu conexión y los permisos.',
              ),
            );
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          return widget.construir(snap.requireData.docs);
        },
      );
}

Future<void> ejecutar(
  BuildContext context,
  Future<void> Function() accion,
) async {
  try {
    await accion();
  } catch (error) {
    if (context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Etiqueta(
            error is StateError
                ? error.message
                : 'No se pudo completar la operación. Revisa tu conexión y vuelve a intentarlo.',
          ),
        ),
      );
  }
}

bool identificar(BuildContext context) {
  if (cliente != null) return true;
  context.push('/iniciarSesion');
  return false;
}

Widget foto(Datos datos, double alto) {
  final url = (datos['imagen'] ?? '').toString().replaceFirst(
        'https://thumb.wikimedia.org/',
        'https://upload.wikimedia.org/',
      );
  final reserva = Container(
    height: alto,
    color: crema,
    alignment: Alignment.center,
    child: Icon(Icons.spa_outlined, size: 48, color: oro),
  );
  return url.startsWith('https://')
      ? Image.network(
          url,
          height: alto,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => reserva,
        )
      : reserva;
}

class _salazarTienda extends StatefulWidget {
  const _salazarTienda(this.seccion, {super.key});
  final String seccion;
  @override
  State<_salazarTienda> createState() => _TiendaState();
}

class _TiendaState extends State<_salazarTienda> {
  String consulta = '', categoria = '', marca = '', orden = 'Nombre';
  bool disponibles = false;
  static const rutas = [
    '/inicio',
    '/catLogo',
    '/favoritos',
    '/carritoDeCompras',
    '/perfilDeUsuario',
  ];
  static const titulos = [
    'Inicio',
    'Catálogo',
    'Favoritos',
    'Carrito',
    'Perfil',
  ];
  static const iconos = [
    Icons.home_outlined,
    Icons.grid_view,
    Icons.favorite_outline,
    Icons.shopping_bag_outlined,
    Icons.person_outline,
  ];
  @override
  Widget build(BuildContext context) {
    final seccion = widget.seccion;
    final indice = titulos.indexOf(seccion);
    Widget cuerpo;
    if (seccion == 'Inicio' || seccion == 'Catálogo') {
      cuerpo = catalogo(seccion == 'Inicio');
    } else if (cliente == null) {
      cuerpo = Center(
        child: FilledButton(
          onPressed: () => context.push('/iniciarSesion'),
          child: Etiqueta(
              'Iniciar sesión para acceder a ${seccion.toLowerCase()}'),
        ),
      );
    } else {
      cuerpo = switch (seccion) {
        'Favoritos' => Resultados(
            perfil.collection('favoritos'),
            (favoritos) => favoritos.isEmpty
                ? vacio('Aún no has guardado perfumes.')
                : Resultados(
                    _salazarDb.collection('products').where('activo', isEqualTo: true),
                    (productos) => tarjetas(
                      productos
                          .where((p) => favoritos.any((f) => f.id == p.id))
                          .toList(),
                    ),
                  ),
          ),
        'Carrito' ||
        'Confirmar pedido' =>
          Carrito(confirmar: seccion == 'Confirmar pedido'),
        'Mis pedidos' => const Pedidos(),
        'Administración' => const Administracion(),
        _ => const Perfil(),
      };
    }
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: tinta,
        foregroundColor: Colors.white,
        title: Etiqueta(seccion == 'Inicio' ? 'Perfumes Salazar' : seccion),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SizedBox.expand(child: cuerpo),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: seccion == 'Confirmar pedido'
            ? 3
            : indice < 0
                ? 4
                : indice,
        selectedItemColor: const Color(0xff795414),
        onTap: (i) => context.go(rutas[i]),
        items: [
          for (var i = 0; i < 5; i++)
            BottomNavigationBarItem(
                icon: Icon(iconos[i]), label: traducir(context, titulos[i])),
        ],
      ),
    );
  }

  Widget vacio(String texto) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Etiqueta(texto),
            TextButton(
              onPressed: () => context.go('/catLogo'),
              child: const Etiqueta('Explorar catálogo'),
            ),
          ],
        ),
      );
  Widget catalogo(bool inicio) => Resultados(
        _salazarDb.collection('products').where('activo', isEqualTo: true),
        (lista) => Resultados(
            _salazarDb.collection('categorias').where('activa', isEqualTo: true),
            (catalogoCategorias) => Resultados(
                    _salazarDb.collection('marcas').where('activa', isEqualTo: true),
                    (catalogoMarcas) {
                  final marcas = catalogoMarcas
                      .map((m) => m.data()['nombre']?.toString() ?? '')
                      .where((s) => s.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
                  final filtroMarca = marcas.contains(marca) ? marca : '';
                  final categorias = catalogoCategorias
                      .map((e) => e.data()['nombre']?.toString() ?? '')
                      .where((e) => e.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
                  final visibles = lista.where((p) {
                    final d = p.data();
                    return (!categorias.contains(categoria) ||
                            d['categoria'] == categoria) &&
                        (filtroMarca.isEmpty || d['marca'] == filtroMarca) &&
                        (!disponibles || entero(d['stock']) > 0) &&
                        coincidePerfume(
                          consulta,
                          '${d['nombre']}',
                          '${d['marca']}',
                          '${d['aroma']} ${d['notas']}',
                        );
                  }).toList();
                  visibles.sort(
                    (a, b) => orden == 'Nombre'
                        ? '${a.data()['nombre']}'
                            .compareTo('${b.data()['nombre']}')
                        : (orden == 'Menor precio' ? 1 : -1) *
                            entero(a.data()['precio'])
                                .compareTo(entero(b.data()['precio'])),
                  );
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (inicio)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 32),
                          decoration: BoxDecoration(
                              color: tinta,
                              border: Border(
                                  left: BorderSide(color: oro, width: 5))),
                          child: Row(children: [
                            Expanded(
                                child: const Etiqueta('Colección de perfumes',
                                    style: TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 35,
                                        color: Colors.white))),
                            const SizedBox(width: 16),
                            const Icon(Icons.spa_outlined, size: 46, color: oro)
                          ]),
                        ),
                      if (inicio) const Promociones(),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: traducir(
                              context, 'Buscar por nombre, marca o aroma'),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => consulta = v),
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final c in ['', ...categorias])
                            ChoiceChip(
                              label: Etiqueta(c.isEmpty ? 'Todos' : c),
                              selected: c == categoria,
                              onSelected: (_) => setState(() => categoria = c),
                            ),
                        ],
                      ),
                      Wrap(
                          spacing: 20,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            DropdownButton<String>(
                                value: filtroMarca,
                                items: [
                                  DropdownMenuItem(
                                      value: '',
                                      child: Etiqueta('Todas las marcas')),
                                  for (final m in marcas)
                                    DropdownMenuItem(value: m, child: Text(m))
                                ],
                                onChanged: (v) =>
                                    setState(() => marca = v ?? '')),
                            FilterChip(
                                label: const Etiqueta('En existencia'),
                                selected: disponibles,
                                onSelected: (v) =>
                                    setState(() => disponibles = v)),
                            DropdownButton<String>(
                              value: orden,
                              items: [
                                for (final o in [
                                  'Nombre',
                                  'Menor precio',
                                  'Mayor precio'
                                ])
                                  DropdownMenuItem(
                                      value: o, child: Etiqueta(o)),
                              ],
                              onChanged: (v) => setState(() => orden = v!),
                            ),
                          ]),
                      const SizedBox(height: 12),
                      if (visibles.isEmpty)
                        const Etiqueta('No se encontraron perfumes.')
                      else
                        rejilla(visibles),
                    ],
                  );
                })),
      );
  Widget tarjetas(List<Ficha> p) => p.isEmpty
      ? vacio('No hay perfumes disponibles en esta lista.')
      : ListView(padding: const EdgeInsets.all(16), children: [rejilla(p)]);
  Widget rejilla(List<Ficha> lista) => LayoutBuilder(
        builder: (_, caja) {
          final columnas = (caja.maxWidth / 170).floor().clamp(1, 4);
          final ancho = (caja.maxWidth - 12 * (columnas - 1)) / columnas;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in lista)
                SizedBox(
                  width: ancho,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(Uri(
                          path: '/detalleDeProducto',
                          queryParameters: {'productoRef': p.id}).toString()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          foto(p.data(), 145),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p.data()['marca']}',
                                  style:
                                      const TextStyle(color: Color(0xff795414)),
                                ),
                                Text(
                                  '${p.data()['nombre']}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Etiqueta(
                                  'Precio: ${formatoColones(entero(p.data()['precio']))}',
                                ),
                                Etiqueta(
                                    'Cantidad: ${entero(p.data()['stock'])}'),
                                Favorito(p.reference),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

class Favorito extends StatelessWidget {
  const Favorito(this.producto, {super.key});
  final DocumentReference<Datos> producto;
  @override
  Widget build(BuildContext context) {
    if (cliente == null)
      return IconButton(
        tooltip: traducir(context, 'Guardar en favoritos'),
        icon: const Icon(Icons.favorite_border),
        onPressed: () => identificar(context),
      );
    final ref = perfil.collection('favoritos').doc(producto.id);
    return StreamBuilder<DocumentSnapshot<Datos>>(
      stream: ref.snapshots(),
      builder: (_, snap) {
        final guardado = snap.data?.exists == true;
        return IconButton(
          tooltip: traducir(context,
              guardado ? 'Quitar de favoritos' : 'Guardar en favoritos'),
          icon: Icon(
            guardado ? Icons.favorite : Icons.favorite_border,
            color: oro,
          ),
          onPressed: !snap.hasData
              ? null
              : () => ejecutar(context, () async {
                    if (guardado) {
                      await ref.delete();
                    } else {
                      await ref.set({
                        'producto_ref': producto,
                        'created_time': FieldValue.serverTimestamp(),
                      });
                    }
                  }),
        );
      },
    );
  }
}

class _salazarDetalle extends StatelessWidget {
  const _salazarDetalle(this.producto, {super.key});
  final DocumentReference<Datos> producto;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Etiqueta('Detalle del perfume')),
        body: StreamBuilder<DocumentSnapshot<Datos>>(
          stream: producto.snapshots(),
          builder: (_, snap) {
            if (snap.hasError || (snap.hasData && !snap.requireData.exists))
              return const Center(
                child: Etiqueta('Este producto ya no está disponible.'),
              );
            if (!snap.hasData)
              return const Center(child: CircularProgressIndicator());
            final d = snap.requireData.data()!;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                foto(d, 230),
                Text('${d['marca']}'),
                Text(
                  '${d['nombre']}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text('${d['descripcion'] ?? ''}'),
                NotasOlfativas(notas: '${d['notas'] ?? ''}'),
                Favorito(producto),
                IndicadorStock(stock: entero(d['stock'])),
                Resultados(
                  _salazarDb
                      .collection('presentaciones')
                      .where('activa', isEqualTo: true),
                  (variantes) {
                    final opciones = variantes.where(
                      (v) => v.data()['producto_id'] == producto.id,
                    );
                    if (opciones.isEmpty)
                      return const Etiqueta('Sin presentaciones disponibles.');
                    return Column(
                      children: [
                        for (final v in opciones)
                          ListTile(
                            title: Etiqueta(
                              '${v.data()['ml']} ml · ${formatoColones(entero(v.data()['precio']))}',
                            ),
                            subtitle:
                                Etiqueta('Cantidad: ${v.data()['stock']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              tooltip: traducir(context, 'Agregar al carrito'),
                              onPressed: entero(v.data()['stock']) < 1
                                  ? null
                                  : () => ejecutar(context, () async {
                                        if (!identificar(context)) return;
                                        await cambiarCantidad(v.reference, 1);
                                        if (context.mounted)
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Etiqueta(
                                                  'Agregado al carrito.'),
                                            ),
                                          );
                                      }),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      );
}

class Promociones extends StatelessWidget {
  const Promociones({super.key});
  @override
  Widget build(BuildContext context) => Resultados(
        _salazarDb.collection('promociones').where('activa', isEqualTo: true),
        (docs) => Column(
          children: [
            for (final p in docs.where((d) => vigente(d.data())))
              ListTile(
                leading: const Icon(Icons.local_offer_outlined),
                title: Etiqueta('${p.data()['porcentaje']} % de descuento'),
                subtitle: SelectableText('Código: ${p.id}'),
              ),
          ],
        ),
      );
}

bool vigente(Datos d) {
  final inicio = d['inicio'], fin = d['fin'], ahora = DateTime.now();
  return d['activa'] == true &&
      inicio is Timestamp &&
      fin is Timestamp &&
      !inicio.toDate().isAfter(ahora) &&
      fin.toDate().isAfter(ahora);
}

Future<void> cambiarCantidad(
  DocumentReference<Datos> variante,
  int incremento,
) async {
  final linea = perfil.collection('carrito').doc(variante.id);
  await _salazarDb.runTransaction((tx) async {
    final v = (await tx.get(variante)).data();
    final anterior = (await tx.get(linea)).data();
    final cantidad = entero(anterior?['cantidad']) + incremento;
    if (cantidad <= 0) {
      tx.delete(linea);
      return;
    }
    if (v == null ||
        v['activa'] != true ||
        !cantidadDisponible(cantidad, entero(v['stock'])) ||
        cantidad > 99)
      throw StateError('No hay suficientes unidades disponibles.');
    tx.set(linea, {'presentacion_ref': variante, 'cantidad': cantidad});
  });
}

Future<Datos> llamar(String funcion, Datos datos) async {
  final token = await cliente!.getIdToken();
  final project = Firebase.app().options.projectId;
  final url = entornoLocal
      ? Uri.http('127.0.0.1:5001', '/$project/us-central1/$funcion')
      : Uri.https('us-central1-$project.cloudfunctions.net', '/$funcion');
  final respuesta = await http
      .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'data': datos}),
      )
      .timeout(const Duration(seconds: 30));
  if (respuesta.statusCode != 200) {
    String mensaje =
        'El servicio de pedidos no está disponible. Tu carrito se conserva.';
    try {
      mensaje = jsonDecode(respuesta.body)['error']['message'] as String;
    } catch (_) {}
    throw StateError(mensaje);
  }
  return Map<String, dynamic>.from(jsonDecode(respuesta.body)['result'] as Map);
}

class Carrito extends StatefulWidget {
  const Carrito({required this.confirmar, super.key});
  final bool confirmar;
  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  final cupon = TextEditingController();
  bool enviando = false;
  String? firmaSolicitud, solicitudPendiente;
  String codigo = '';
  @override
  void dispose() {
    cupon.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      Resultados(perfil.collection('carrito'), (lineas) {
        if (lineas.isEmpty)
          return Center(
            child: TextButton(
              onPressed: () => context.go('/catLogo'),
              child: const Etiqueta('Carrito vacío · Explorar catálogo'),
            ),
          );
        return Resultados(
          _salazarDb.collection('presentaciones').where('activa', isEqualTo: true),
          (variantes) => Resultados(
            _salazarDb.collection('products').where('activo', isEqualTo: true),
            (productos) => Resultados(
              _salazarDb.collection('promociones').where('activa', isEqualTo: true),
              (promos) {
                final vs = {for (final v in variantes) v.id: v.data()};
                final ps = {for (final p in productos) p.id: p.data()};
                final promo = promos
                    .where((p) => p.id == codigo && vigente(p.data()))
                    .firstOrNull;
                final subtotal = lineas.fold<int>(
                  0,
                  (t, l) =>
                      t +
                      calcularSubtotal(
                        entero(vs[l.id]?['precio']),
                        entero(l.data()['cantidad']),
                      ),
                );
                final descuento = calcularDescuento(
                  subtotal,
                  entero(promo?.data()['porcentaje']),
                );
                final disponibles = lineas.every(
                  (l) =>
                      ps.containsKey(vs[l.id]?['producto_id']) &&
                      cantidadDisponible(
                        entero(l.data()['cantidad']),
                        entero(vs[l.id]?['stock']),
                      ),
                );
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final l in lineas)
                      Card(
                        child: ListTile(
                          title: Etiqueta(
                            '${ps[vs[l.id]?['producto_id']]?['nombre'] ?? 'Producto no disponible'} · ${vs[l.id]?['ml'] ?? '—'} ml',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Etiqueta(
                                'Precio: ${formatoColones(entero(vs[l.id]?['precio']))}',
                              ),
                              Etiqueta('Cantidad: ${l.data()['cantidad']}'),
                              if (!widget.confirmar)
                                Wrap(
                                  children: [
                                    IconButton(
                                      tooltip: traducir(context, 'Disminuir'),
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => ejecutar(
                                        context,
                                        () => cambiarCantidad(
                                          _salazarDb
                                              .collection('presentaciones')
                                              .doc(l.id),
                                          -1,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: traducir(context, 'Aumentar'),
                                      icon: const Icon(Icons.add),
                                      onPressed: () => ejecutar(
                                        context,
                                        () => cambiarCantidad(
                                          _salazarDb
                                              .collection('presentaciones')
                                              .doc(l.id),
                                          1,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: traducir(context, 'Quitar'),
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () =>
                                          ejecutar(context, l.reference.delete),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (!disponibles)
                      const Etiqueta(
                        'Revisa los artículos agotados antes de confirmar.',
                      ),
                    if (widget.confirmar) ...[
                      TextField(
                        controller: cupon,
                        decoration: InputDecoration(
                          labelText: traducir(context, 'Código de promoción'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(
                          () => codigo = cupon.text.toUpperCase().trim(),
                        ),
                        child: const Etiqueta('Aplicar código'),
                      ),
                      if (codigo.isNotEmpty && promo == null)
                        const Etiqueta('El código no está vigente.'),
                    ],
                    Etiqueta('Subtotal: ${formatoColones(subtotal)}'),
                    Etiqueta('Descuento: ${formatoColones(descuento)}'),
                    Etiqueta(
                      'Total: ${formatoColones(subtotal - descuento)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    FilledButton(
                      onPressed: !disponibles ||
                              enviando ||
                              (codigo.isNotEmpty && promo == null)
                          ? null
                          : () => ejecutar(context, () async {
                                if (!widget.confirmar) {
                                  context.push('/confirmarPedido');
                                  return;
                                }
                                if (enviando) return;
                                setState(() => enviando = true);
                                try {
                                  final firma = jsonEncode([
                                    cliente!.uid,
                                    codigo,
                                    subtotal - descuento,
                                    for (final l in lineas)
                                      [l.id, l.data()['cantidad']]
                                  ]);
                                  if (firma != firmaSolicitud) {
                                    firmaSolicitud = firma;
                                    solicitudPendiente =
                                        _salazarDb.collection('pedidos').doc().id;
                                  }
                                  final solicitud = solicitudPendiente!;
                                  await llamar('crearPedido', {
                                    'solicitudId': solicitud,
                                    'items': [
                                      for (final l in lineas)
                                        {
                                          'presentacionId': l.id,
                                          'cantidad': l.data()['cantidad'],
                                        },
                                    ],
                                    if (codigo.isNotEmpty) 'codigo': codigo,
                                    'desdeCarrito': true,
                                    'totalEsperado': subtotal - descuento,
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Etiqueta('Solicitud enviada.'),
                                      ),
                                    );
                                    context.go('/misPedidos');
                                  }
                                } finally {
                                  if (mounted) setState(() => enviando = false);
                                }
                              }),
                      child: Etiqueta(
                        enviando
                            ? 'Enviando…'
                            : widget.confirmar
                                ? 'Enviar solicitud de pedido'
                                : 'Revisar pedido',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      });
}

class Pedidos extends StatelessWidget {
  const Pedidos({super.key, this.admin = false});
  final bool admin;
  @override
  Widget build(BuildContext context) {
    final todos = _salazarDb.collection('pedidos');
    return Resultados(
        admin ? todos : todos.where('user_ref', isEqualTo: perfil), (
      lista,
    ) {
      lista = [...lista]..sort(
          (a, b) => entero(
            (b.data()['created_time'] as Timestamp?)?.millisecondsSinceEpoch,
          ).compareTo(
            entero(
              (a.data()['created_time'] as Timestamp?)?.millisecondsSinceEpoch,
            ),
          ),
        );
      if (lista.isEmpty)
        return const Center(child: Etiqueta('Todavía no hay pedidos.'));
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          for (final p in lista)
            Card(
              child: ExpansionTile(
                title: Etiqueta(
                  'Pedido ${p.id.substring(0, p.id.length.clamp(0, 8))}',
                ),
                subtitle: EstadoPedido(estado: '${p.data()['estado']}'),
                children: [
                  for (final item in p.data()['items'] ?? [])
                    ListTile(
                      title: Etiqueta('${item['nombre']} · ${item['ml']} ml'),
                      subtitle: Etiqueta(
                        'Cantidad: ${item['cantidad']} · Precio: ${formatoColones(entero(item['precio_unitario']))}',
                      ),
                    ),
                  Etiqueta(
                      'Total: ${formatoColones(entero(p.data()['total']))}'),
                  if (!admin && p.data()['estado'] == 'pendiente')
                    TextButton(
                      onPressed: () => ejecutar(context, () async {
                        if (await confirmarAccion(
                          context,
                          '¿Cancelar este pedido y devolver las unidades al inventario?',
                        )) await llamar('cancelarPedido', {'pedidoId': p.id});
                      }),
                      child: const Etiqueta('Cancelar pedido'),
                    ),
                  if (admin && siguiente.containsKey(p.data()['estado']))
                    FilledButton(
                      onPressed: () => ejecutar(
                        context,
                        () => p.reference.update({
                          'estado': siguiente[p.data()['estado']],
                        }),
                      ),
                      child: Etiqueta(
                        'Marcar como ${siguiente[p.data()['estado']]?.replaceAll('_', ' ')}',
                      ),
                    ),
                  TextButton(
                    onPressed: () => ejecutar(context, () async {
                      final numero =
                          const String.fromEnvironment('WHATSAPP_COMERCIO')
                              .replaceAll(RegExp(r'[^0-9]'), '');
                      final url = Uri.https('wa.me', '/$numero', {
                        'text':
                            'Consulta sobre mi pedido de Perfumes Salazar: ${p.id}.',
                      });
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      )) throw StateError('No se pudo abrir WhatsApp.');
                    }),
                    child: const Etiqueta(
                        String.fromEnvironment('WHATSAPP_COMERCIO') == ''
                            ? 'Compartir consulta por WhatsApp'
                            : 'Contactar a la tienda por WhatsApp'),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  static const siguiente = {
    'pendiente': 'confirmado',
    'confirmado': 'en_preparacion',
    'en_preparacion': 'entregado',
  };
}

Future<bool> confirmarAccion(BuildContext context, String mensaje) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Etiqueta(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Etiqueta('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Etiqueta('Confirmar'),
          ),
        ],
      ),
    ) ??
    false;

class Perfil extends StatelessWidget {
  const Perfil({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Datos>>(
        stream: perfil.snapshots(),
        builder: (_, snap) {
          final data = snap.data?.data() ?? {};
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Etiqueta(
                data['display_name'] ?? cliente?.displayName ?? 'Mi perfil',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(cliente?.email ?? ''),
              Text(data['phone_number'] ?? ''),
              ListTile(
                title: const Etiqueta('Editar información personal'),
                onTap: () => ejecutar(context, () async {
                  final nuevo = await formulario(
                      context,
                      'Mi perfil',
                      {
                        'display_name': 'Nombre',
                        'phone_number': 'Teléfono',
                      },
                      data);
                  if (nuevo != null)
                    await perfil.set({
                      ...nuevo,
                      'uid': cliente!.uid,
                    }, SetOptions(merge: true));
                }),
              ),
              ListTile(
                title: const Etiqueta('Mis pedidos'),
                onTap: () => context.push('/misPedidos'),
              ),
              ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Etiqueta('Idioma de la aplicación'),
                  trailing: DropdownButton<String>(
                      value: idiomaApp.value.languageCode,
                      items: const [
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) =>
                          ejecutar(context, () => cambiarIdioma(v!)))),
              if (data['role'] == 'admin')
                ListTile(
                  title: const Etiqueta('Panel de administración'),
                  onTap: () => context.push('/panelDeAdministraciN'),
                ),
              ListTile(
                title: const Etiqueta('Cerrar sesión'),
                onTap: () => ejecutar(context, () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/bienvenida');
                }),
              ),
            ],
          );
        },
      );
}

Future<Map<String, String>?> formulario(
  BuildContext context,
  String titulo,
  Map<String, String> campos,
  Datos inicial,
) {
  final valores = {for (final k in campos.keys) k: '${inicial[k] ?? ''}'};
  final clave = GlobalKey<FormState>();
  return showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Etiqueta(titulo),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: clave,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final c in campos.entries)
                  TextFormField(
                    initialValue: valores[c.key],
                    decoration:
                        InputDecoration(labelText: traducir(context, c.value)),
                    onChanged: (v) => valores[c.key] = v.trim(),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty &&
                          !['phone_number', 'imagen', 'notas'].contains(c.key))
                        return traducir(context, 'Completa este campo.');
                      if ([
                        'stock',
                        'precio',
                        'ml',
                        'porcentaje',
                      ].contains(c.key)) {
                        final n = int.tryParse(t);
                        if (n == null ||
                            n < (c.key == 'stock' ? 0 : 1) ||
                            (c.key == 'porcentaje' && n > 100))
                          return traducir(context, 'Ingresa un entero válido.');
                      }
                      if (c.key == 'imagen' &&
                          t.isNotEmpty &&
                          Uri.tryParse(t)?.scheme != 'https')
                        return traducir(context, 'Usa una dirección HTTPS.');
                      if (['inicio', 'fin'].contains(c.key) &&
                          DateTime.tryParse(t) == null)
                        return traducir(context, 'Usa el formato AAAA-MM-DD.');
                      return null;
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Etiqueta('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (clave.currentState!.validate()) Navigator.pop(ctx, valores);
          },
          child: const Etiqueta('Guardar'),
        ),
      ],
    ),
  );
}

class Administracion extends StatelessWidget {
  const Administracion({super.key});
  static const grupos = ['products', 'categorias', 'marcas', 'promociones'];
  static const nombres = ['Productos', 'Categorías', 'Marcas', 'Promociones'];
  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Datos>>(
        stream: perfil.snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.data?.data()?['role'] != 'admin')
            return const Center(
              child: Etiqueta('Acceso reservado al personal administrador.'),
            );
          return DefaultTabController(
            length: 6,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: tinta,
                  tabs: [
                    Tab(text: traducir(context, 'Resumen')),
                    Tab(text: traducir(context, 'Pedidos')),
                    for (final s in nombres) Tab(text: traducir(context, s)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      const _Resumen(),
                      const Pedidos(admin: true),
                      for (var i = 0; i < grupos.length; i++)
                        _Gestion(grupos[i], nombres[i]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _Resumen extends StatelessWidget {
  const _Resumen();
  @override
  Widget build(BuildContext context) => Resultados(
        _salazarDb.collection('products'),
        (productos) => Resultados(
          _salazarDb.collection('pedidos'),
          (pedidos) => ListView(
            children: [
              ListTile(
                title: const Etiqueta('Productos activos'),
                trailing: Etiqueta(
                  '${productos.where((p) => p.data()['activo'] == true).length}',
                ),
              ),
              ListTile(
                title: const Etiqueta('Productos agotados'),
                trailing: Etiqueta(
                  '${productos.where((p) => entero(p.data()['stock']) == 0).length}',
                ),
              ),
              ListTile(
                title: const Etiqueta('Pedidos pendientes'),
                trailing: Etiqueta(
                  '${pedidos.where((p) => p.data()['estado'] == 'pendiente').length}',
                ),
              ),
              ListTile(
                title: const Etiqueta('Total entregado'),
                trailing: Etiqueta(
                  formatoColones(
                    pedidos
                        .where((p) => p.data()['estado'] == 'entregado')
                        .fold<int>(0, (t, p) => t + entero(p.data()['total'])),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Gestion extends StatelessWidget {
  const _Gestion(this.grupo, this.nombre);
  final String grupo, nombre;
  String get activo => grupo == 'products' ? 'activo' : 'activa';
  @override
  Widget build(BuildContext context) => Resultados(
        _salazarDb.collection(grupo),
        (docs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: () => ejecutar(context, () => editar(context, null)),
              icon: const Icon(Icons.add),
              label: Etiqueta('Agregar · $nombre'),
            ),
            for (final d in docs)
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Etiqueta('${d.data()['nombre'] ?? d.id}'),
                      subtitle: Etiqueta(
                        d.data()[activo] == true ? 'Visible' : 'Oculto',
                      ),
                      onTap: () => ejecutar(context, () => editar(context, d)),
                      trailing: Switch(
                        value: d.data()[activo] == true,
                        onChanged: (v) => ejecutar(
                          context,
                          () => d.reference.update({activo: v}),
                        ),
                      ),
                    ),
                    if (grupo == 'products')
                      OutlinedButton(
                        onPressed: () =>
                            ejecutar(context, () => variantes(context, d)),
                        child: const Etiqueta('Gestionar presentaciones'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
  Future<void> editar(BuildContext context, Ficha? doc) async {
    final inicial = {...?doc?.data()};
    final campos = switch (grupo) {
      'products' => {
          'nombre': 'Nombre',
          'marca': 'Marca',
          'categoria': 'Categoría',
          'aroma': 'Familia olfativa',
          'notas': 'Notas',
          'descripcion': 'Descripción',
          'imagen': 'URL de la imagen',
        },
      'promociones' => {
          if (doc == null) 'codigo': 'Código',
          'porcentaje': 'Porcentaje',
          'inicio': 'Desde (AAAA-MM-DD)',
          'fin': 'Hasta (fecha exclusiva)',
        },
      _ => {'nombre': 'Nombre'},
    };
    for (final k in ['inicio', 'fin']) {
      final t = inicial[k];
      if (t is Timestamp)
        inicial[k] = t.toDate().toIso8601String().substring(0, 10);
    }
    final valores = await formulario(context, nombre, campos, inicial);
    if (valores == null) return;
    final datos = <String, dynamic>{...valores, if (doc == null) activo: true};
    final col = _salazarDb.collection(grupo);
    var ref = doc?.reference ?? col.doc();
    if (grupo == 'products' && doc == null)
      datos.addAll({'stock': 0, 'precio': 0, 'activo': false});
    if (grupo == 'promociones') {
      final codigo = (valores['codigo'] ?? doc!.id).toUpperCase();
      if (!RegExp(r'^[A-Z0-9_-]{1,80}$').hasMatch(codigo))
        throw StateError('Usa letras, números, guion o guion bajo.');
      final inicio = DateTime.parse(valores['inicio']!),
          fin = DateTime.parse(valores['fin']!);
      if (!fin.isAfter(inicio))
        throw StateError('La fecha final debe ser posterior a la inicial.');
      ref = col.doc(codigo);
      datos.addAll({
        'codigo': codigo,
        'porcentaje': int.parse(valores['porcentaje']!),
        'inicio': Timestamp.fromDate(inicio),
        'fin': Timestamp.fromDate(fin),
      });
    }
    await _salazarDb.runTransaction((tx) async {
      if (doc == null && (await tx.get(ref)).exists)
        throw StateError('Ese código ya existe.');
      tx.set(ref, datos, SetOptions(merge: true));
    });
  }

  Future<void> variantes(BuildContext context, Ficha producto) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Etiqueta('${producto.data()['nombre']}'),
        content: SizedBox(
          width: 400,
          child: Resultados(
            _salazarDb
                .collection('presentaciones')
                .where('producto_id', isEqualTo: producto.id),
            (docs) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final v in docs)
                    ListTile(
                      title: Etiqueta(
                        '${v.data()['ml']} ml · ${formatoColones(entero(v.data()['precio']))}',
                      ),
                      subtitle: Etiqueta('Cantidad: ${v.data()['stock']}'),
                      onTap: () =>
                          ejecutar(ctx, () => editarVariante(ctx, producto, v)),
                    ),
                  TextButton(
                    onPressed: () => ejecutar(
                      ctx,
                      () => editarVariante(ctx, producto, null),
                    ),
                    child: const Etiqueta('Agregar presentación'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Etiqueta('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> editarVariante(BuildContext context, Ficha p, Ficha? v) async {
    final valores = await formulario(
        context,
        'Presentación',
        {
          'ml': 'Volumen (ml)',
          'precio': 'Precio en colones',
          'stock': 'Cantidad',
        },
        v?.data() ?? {});
    if (valores == null) return;
    final ref = v?.reference ?? _salazarDb.collection('presentaciones').doc();
    final stock = int.parse(valores['stock']!),
        precio = int.parse(valores['precio']!);
    await _salazarDb.runTransaction((tx) async {
      final producto = (await tx.get(p.reference)).data()!;
      final previa = (await tx.get(ref)).data();
      if (previa != null && previa['stock'] != v?.data()['stock'])
        throw StateError(
          'El inventario cambió. Abre la presentación de nuevo.',
        );
      tx.set(ref, {
        'producto_id': p.id,
        'activa': true,
        'stock': stock,
        'precio': precio,
        'ml': int.parse(valores['ml']!),
      });
      tx.update(p.reference, {
        'stock': entero(producto['stock']) + stock - entero(previa?['stock']),
        'precio': precio,
      });
    });
  }
}

class _salazarAcceso extends StatefulWidget {
  const _salazarAcceso(this.modo, {super.key});
  final String modo;
  @override
  State<_salazarAcceso> createState() => _AccesoState();
}

class _AccesoState extends State<_salazarAcceso> {
  final form = GlobalKey<FormState>();
  final correo = TextEditingController(), clave = TextEditingController();
  bool ocupado = false, ocultar = true;
  String mensaje = '';
  @override
  void dispose() {
    correo.dispose();
    clave.dispose();
    super.dispose();
  }

  Future<void> enviar({bool google = false}) async {
    if (ocupado || (!google && !form.currentState!.validate())) return;
    setState(() {
      ocupado = true;
      mensaje = '';
    });
    try {
      final auth = FirebaseAuth.instance;
      await auth.setLanguageCode(idiomaApp.value.languageCode);
      if (widget.modo == 'Recuperar contraseña' && !google) {
        await auth.sendPasswordResetEmail(email: correo.text.trim());
        if (mounted)
          setState(
            () => mensaje =
                'Si tienes una cuenta, recibirás un enlace para restablecer tu contraseña.',
          );
        return;
      }
      final cred = google
          ? await auth.signInWithPopup(GoogleAuthProvider())
          : widget.modo == 'Crear cuenta'
              ? await auth.createUserWithEmailAndPassword(
                  email: correo.text.trim(),
                  password: clave.text,
                )
              : await auth.signInWithEmailAndPassword(
                  email: correo.text.trim(),
                  password: clave.text,
                );
      await maybeCreateUser(cred.user!);
      if (mounted) context.go('/inicio');
    } on FirebaseAuthException catch (e) {
      if (mounted)
        setState(
          () => mensaje = switch (e.code) {
            'email-already-in-use' => 'Ese correo ya tiene una cuenta.',
            'weak-password' => 'La contraseña es demasiado corta.',
            'popup-closed-by-user' => 'Se cerró el acceso con Google.',
            'network-request-failed' => 'Revisa tu conexión a Internet.',
            _ =>
              'No se pudo iniciar la operación. Revisa los datos e inténtalo de nuevo.',
          },
        );
    } catch (_) {
      if (mounted)
        setState(
          () => mensaje =
              'No se pudo cargar el perfil. Comprueba la conexión y los permisos.',
        );
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registro = widget.modo == 'Crear cuenta',
        recuperar = widget.modo == 'Recuperar contraseña';
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        title: const Etiqueta('Perfumes Salazar'),
        backgroundColor: tinta,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Etiqueta(
                    widget.modo,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: correo,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: traducir(context, 'Correo electrónico'),
                    ),
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : traducir(context, 'Ingresa un correo válido.'),
                  ),
                  if (!recuperar)
                    TextFormField(
                      controller: clave,
                      obscureText: ocultar,
                      decoration: InputDecoration(
                        labelText: traducir(context, 'Contraseña'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultar ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => ocultar = !ocultar),
                        ),
                      ),
                      validator: (v) => (v ?? '').length < (registro ? 6 : 1)
                          ? traducir(context, 'Revisa la contraseña.')
                          : null,
                    ),
                  if (registro)
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: traducir(context, 'Confirmar contraseña'),
                      ),
                      validator: (v) => v == clave.text
                          ? null
                          : traducir(context, 'Las contraseñas no coinciden.'),
                    ),
                  if (mensaje.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Etiqueta(mensaje),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: ocupado ? null : () => enviar(),
                    child: Etiqueta(recuperar ? 'Enviar enlace' : widget.modo),
                  ),
                  if (!recuperar)
                    OutlinedButton(
                      onPressed: ocupado ? null : () => enviar(google: true),
                      child: const Etiqueta('Continuar con Google'),
                    ),
                  if (!recuperar && !registro)
                    TextButton(
                      onPressed: () => context.push('/recuperarContrasena'),
                      child: const Etiqueta('Olvidé mi contraseña'),
                    ),
                  TextButton(
                    onPressed: () => context.go(
                      registro || recuperar ? '/iniciarSesion' : '/registro',
                    ),
                    child: Etiqueta(
                      registro || recuperar ? 'Iniciar sesión' : 'Crear cuenta',
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/catLogo'),
                    child: const Etiqueta('Explorar como invitado'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final idiomaApp = ValueNotifier<Locale>(const Locale('es', 'CR'));
Future<void> cargarIdioma() async {
  final preferencias = await SharedPreferences.getInstance();
  if (preferencias.getString('idioma') == 'en')
    idiomaApp.value = const Locale('en');
}

Future<void> cambiarIdioma(String codigo) async {
  final preferencias = await SharedPreferences.getInstance();
  await preferencias.setString('idioma', codigo);
  idiomaApp.value =
      codigo == 'en' ? const Locale('en') : const Locale('es', 'CR');
}

const _ingles = <String, String>{
  "Inicio": "Home",
  "Catálogo": "Catalog",
  "Favoritos": "Favorites",
  "Carrito": "Cart",
  "Perfil": "Profile",
  "Administración": "Administration",
  "Confirmar pedido": "Confirm order",
  "Mis pedidos": "My orders",
  "Iniciar sesión": "Sign in",
  "Crear cuenta": "Create account",
  "Recuperar contraseña": "Reset password",
  "Colección de perfumes": "Perfume collection",
  "Buscar por nombre, marca o aroma": "Search by name, brand or scent",
  "Todos": "All",
  "Todas las marcas": "All brands",
  "En existencia": "In stock",
  "Menor precio": "Lowest price",
  "Mayor precio": "Highest price",
  "Nombre": "Name",
  "No se encontraron perfumes.": "No perfumes match your search.",
  "Explorar catálogo": "Explore catalog",
  "Aún no has guardado perfumes.": "You haven’t saved any perfumes yet.",
  "No hay perfumes disponibles en esta lista.":
      "No perfumes are available in this list.",
  "Guardar en favoritos": "Save to favorites",
  "Quitar de favoritos": "Remove from favorites",
  "Detalle del perfume": "Perfume details",
  "Este producto ya no está disponible.":
      "This product is no longer available.",
  "Sin presentaciones disponibles.": "No sizes available.",
  "Agregar al carrito": "Add to cart",
  "Agregado al carrito.": "Added to cart.",
  "Precio": "Price",
  "Cantidad": "Quantity",
  "Descuento": "Discount",
  "Total": "Total",
  "Subtotal": "Subtotal",
  "Código": "Code",
  "Productos": "Products",
  "Categorías": "Categories",
  "Marcas": "Brands",
  "Promociones": "Promotions",
  "Resumen": "Overview",
  "Pedidos": "Orders",
  "Productos activos": "Active products",
  "Productos agotados": "Out-of-stock products",
  "Pedidos pendientes": "Pending orders",
  "Total entregado": "Delivered order value",
  "Correo electrónico": "Email address",
  "Contraseña": "Password",
  "Confirmar contraseña": "Confirm password",
  "Revisa la contraseña.": "Check the password.",
  "Ingresa un correo válido.": "Enter a valid email address.",
  "Las contraseñas no coinciden.": "The passwords do not match.",
  "Enviar enlace": "Send link",
  "Continuar con Google": "Continue with Google",
  "Olvidé mi contraseña": "Forgot my password",
  "Explorar como invitado": "Browse as a guest",
  "Ese correo ya tiene una cuenta.": "This email already has an account.",
  "La contraseña es demasiado corta.": "The password is too short.",
  "Se cerró el acceso con Google.": "Google sign-in was closed.",
  "Revisa tu conexión a Internet.": "Check your internet connection.",
  "No se pudo iniciar la operación. Revisa los datos e inténtalo de nuevo.":
      "Could not complete the request. Check your details and try again.",
  "Si tienes una cuenta, recibirás un enlace para restablecer tu contraseña.":
      "If you have an account, you will receive a password reset link.",
  "No se pudo cargar el perfil. Comprueba la conexión y los permisos.":
      "Could not load your profile. Check your connection and permissions.",
  "Carrito vacío · Explorar catálogo": "Your cart is empty · Explore catalog",
  "Disminuir": "Decrease",
  "Aumentar": "Increase",
  "Quitar": "Remove",
  "Revisa los artículos agotados antes de confirmar.":
      "Review unavailable items before confirming.",
  "Código de promoción": "Promo code",
  "Aplicar código": "Apply code",
  "El código no está vigente.": "This code is not valid.",
  "Solicitud enviada.": "Order request sent.",
  "Enviando…": "Sending…",
  "Enviar solicitud de pedido": "Submit order request",
  "Revisar pedido": "Review order",
  "Todavía no hay pedidos.": "No orders yet.",
  "Cancelar pedido": "Cancel order",
  "Compartir consulta por WhatsApp": "Share inquiry on WhatsApp",
  "Contactar a la tienda por WhatsApp": "Contact the store on WhatsApp",
  "¿Cancelar este pedido y devolver las unidades al inventario?":
      "Cancel this order and return its items to stock?",
  "Volver": "Back",
  "Confirmar": "Confirm",
  "Editar información personal": "Edit personal information",
  "Mi perfil": "My profile",
  "Teléfono": "Phone number",
  "Panel de administración": "Admin dashboard",
  "Cerrar sesión": "Sign out",
  "Idioma de la aplicación": "App language",
  "No se pudieron consultar los datos. Comprueba tu conexión y los permisos.":
      "Could not load the data. Check your connection and access permissions.",
  "No se pudo completar la operación. Revisa tu conexión y vuelve a intentarlo.":
      "Could not complete the request. Check your connection and try again.",
  "Cancelar": "Cancel",
  "Guardar": "Save",
  "Cerrar": "Close",
  "Acceso reservado al personal administrador.":
      "Administrator access required.",
  "Visible": "Visible",
  "Oculto": "Hidden",
  "Gestionar presentaciones": "Manage sizes",
  "Agregar presentación": "Add size",
  "Presentación": "Size",
  "Familia olfativa": "Fragrance family",
  "Descripción": "Description",
  "Notas": "Notes",
  "URL de la imagen": "Image URL",
  "Marca": "Brand",
  "Categoría": "Category",
  "Porcentaje": "Percentage",
  "Desde (AAAA-MM-DD)": "Start date (YYYY-MM-DD)",
  "Hasta (fecha exclusiva)": "End date (exclusive)",
  "Volumen (ml)": "Volume (ml)",
  "Precio en colones": "Price in colones",
  "Completa este campo.": "Complete this field.",
  "Ingresa un entero válido.": "Enter a valid whole number.",
  "Usa una dirección HTTPS.": "Use an HTTPS address.",
  "Usa el formato AAAA-MM-DD.": "Use the YYYY-MM-DD format.",
  "Pendiente": "Pending",
  "Confirmado": "Confirmed",
  "En preparación": "Preparing",
  "Entregado": "Delivered",
  "Cancelado": "Cancelled",
  "Agotado": "Out of stock",
  "Disponibles": "Available",
  "Sin notas registradas": "No notes listed",
  "Estado sin registrar": "Unknown status",
  "Hombre": "Men",
  "Mujer": "Women",
  "Unisex": "Unisex",
  "LA ESENCIA DE LA ELEGANCIA": "THE ESSENCE OF ELEGANCE",
  "Descubre fragancias exclusivas diseñadas para cautivar tus sentidos.":
      "Discover exclusive fragrances designed to captivate your senses.",
  "INICIAR SESIÓN": "SIGN IN",
  "CREAR CUENTA": "CREATE ACCOUNT",
  "EXPLORAR COMO INVITADO": "BROWSE AS A GUEST",
  "O": "OR",
};
String traducir(BuildContext contexto, String texto) {
  if (Localizations.localeOf(contexto).languageCode != 'en') return texto;
  final valor = _ingles[texto];
  if (valor != null) return valor;
  if (texto.startsWith('Iniciar sesión para acceder a '))
    return 'Sign in to continue';
  if (texto.startsWith('Pedido '))
    return texto.replaceFirst('Pedido ', 'Order ');
  if (texto.startsWith('Agregar · '))
    return 'Add · ${_ingles[texto.substring(10)] ?? texto.substring(10)}';
  if (texto.startsWith('Marcar como '))
    return 'Mark as ${{
          'confirmado': 'confirmed',
          'en preparacion': 'preparing',
          'entregado': 'delivered'
        }[texto.substring(12)] ?? texto.substring(12)}';
  if (texto.endsWith(' % de descuento'))
    return texto.replaceFirst(' % de descuento', '% off');
  return texto
      .replaceAll('Precio: ', 'Price: ')
      .replaceAll('Cantidad: ', 'Quantity: ')
      .replaceAll('Descuento: ', 'Discount: ')
      .replaceAll('Código: ', 'Code: ')
      .replaceAll('Disponibles: ', 'Available: ');
}

class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, this.style});
  final String texto;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) =>
      Text(traducir(context, texto), style: style);
}

String formatoColones(int monto) {
  final formato = NumberFormat.decimalPattern('es_CR');
  return '₡${formato.format(monto)}';
}

bool coincidePerfume(String consulta, String nombre, String marca, String aroma) {
  String normalizar(String texto) {
    const origen = 'áéíóúü';
    const destino = 'aeiouu';
    var resultado = texto.toLowerCase();
    for (var i = 0; i < origen.length; i++) {
      resultado = resultado.replaceAll(origen[i], destino[i]);
    }
    return resultado.trim();
  }

  final palabras = normalizar(consulta).split(RegExp(r'\s+'));
  final texto = normalizar('$nombre $marca $aroma');
  return palabras.every(texto.contains);
}

bool cantidadDisponible(int cantidad, int stock) {
  return cantidad > 0 && cantidad <= stock;
}

int calcularSubtotal(int precioUnitario, int cantidad) {
  if (precioUnitario < 0 || cantidad < 1) return 0;
  return precioUnitario * cantidad;
}

int calcularDescuento(int subtotal, int porcentaje) {
  if (subtotal < 1 || porcentaje < 1 || porcentaje > 100) return 0;
  return (subtotal * porcentaje + 50) ~/ 100;
}

class IndicadorStock extends StatefulWidget {
  const IndicadorStock(
      {super.key, this.width, this.height, required this.stock});

  final double? width;
  final double? height;
  final int stock;

  @override
  State<IndicadorStock> createState() => _IndicadorStockState();
}

class _IndicadorStockState extends State<IndicadorStock> {
  @override
  Widget build(BuildContext context) {
    final disponible = widget.stock > 0;
    final colores = Theme.of(context).colorScheme;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: Chip(
          avatar: Icon(disponible ? Icons.check_circle_outline : Icons.block),
          label:
              Etiqueta(disponible ? 'Disponibles: ${widget.stock}' : 'Agotado'),
          backgroundColor:
              disponible ? colores.secondaryContainer : colores.errorContainer,
        ),
      ),
    );
  }
}

class EstadoPedido extends StatefulWidget {
  const EstadoPedido(
      {super.key, this.width, this.height, required this.estado});

  final double? width;
  final double? height;
  final String estado;

  @override
  State<EstadoPedido> createState() => _EstadoPedidoState();
}

class _EstadoPedidoState extends State<EstadoPedido> {
  @override
  Widget build(BuildContext context) {
    final (etiqueta, icono) = switch (widget.estado) {
      'pendiente' => ('Pendiente', Icons.schedule),
      'confirmado' => ('Confirmado', Icons.check_circle_outline),
      'en_preparacion' => ('En preparación', Icons.inventory_2_outlined),
      'entregado' => ('Entregado', Icons.done_all),
      'cancelado' => ('Cancelado', Icons.cancel_outlined),
      _ => ('Estado sin registrar', Icons.info_outline),
    };
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child:
          Center(child: Chip(avatar: Icon(icono), label: Etiqueta(etiqueta))),
    );
  }
}

class NotasOlfativas extends StatefulWidget {
  const NotasOlfativas(
      {super.key, this.width, this.height, required this.notas});

  final double? width;
  final double? height;
  final String notas;

  @override
  State<NotasOlfativas> createState() => _NotasOlfativasState();
}

class _NotasOlfativasState extends State<NotasOlfativas> {
  @override
  Widget build(BuildContext context) {
    final etiquetas = widget.notas
        .split(RegExp(r'[,;\n]'))
        .map((nota) => nota.trim())
        .where((nota) => nota.isNotEmpty)
        .toSet();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        child: etiquetas.isEmpty
            ? const Etiqueta('Sin notas registradas')
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final nota in etiquetas)
                    Chip(
                        avatar: const Icon(Icons.spa_outlined),
                        label: Text(nota)),
                ],
              ),
      ),
    );
  }
}

const bool entornoLocal = false;
GoRouter crearRutasTienda(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? const _salazarTienda('Inicio') : BienvenidaWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? const _salazarTienda('Inicio') : BienvenidaWidget(),
        ),
        FFRoute(
          name: BienvenidaWidget.routeName,
          path: BienvenidaWidget.routePath,
          builder: (context, params) => BienvenidaWidget(),
        ),
        FFRoute(
          name: InicioWidget.routeName,
          path: InicioWidget.routePath,
          builder: (context, params) => const _salazarTienda('Inicio'),
        ),
        FFRoute(
          name: CatLogoWidget.routeName,
          path: CatLogoWidget.routePath,
          builder: (context, params) => const _salazarTienda('Catálogo'),
        ),
        FFRoute(
          name: DetalleDeProductoWidget.routeName,
          path: DetalleDeProductoWidget.routePath,
          builder: (context, params) {
            final ref = params.getParam('productoRef', ParamType.DocumentReference,
              collectionNamePath: ['products']) as DocumentReference?;
            return ref == null || ref.parent.path != 'products'
              ? const _salazarTienda('Catálogo') : _salazarDetalle(_salazarDb.collection('products').doc(ref.id));
          },
        ),
        FFRoute(
          name: FavoritosWidget.routeName,
          path: FavoritosWidget.routePath,
          builder: (context, params) => const _salazarTienda('Favoritos'),
        ),
        FFRoute(
          name: CarritoDeComprasWidget.routeName,
          path: CarritoDeComprasWidget.routePath,
          builder: (context, params) => const _salazarTienda('Carrito'),
        ),
        FFRoute(
          name: ConfirmarPedidoWidget.routeName,
          path: ConfirmarPedidoWidget.routePath,
          builder: (context, params) => const _salazarTienda('Confirmar pedido'),
        ),
        FFRoute(
          name: MisPedidosWidget.routeName,
          path: MisPedidosWidget.routePath,
          builder: (context, params) => const _salazarTienda('Mis pedidos'),
        ),
        FFRoute(
          name: PerfilDeUsuarioWidget.routeName,
          path: PerfilDeUsuarioWidget.routePath,
          builder: (context, params) => const _salazarTienda('Perfil'),
        ),
        FFRoute(
          name: PanelDeAdministraciNWidget.routeName,
          path: PanelDeAdministraciNWidget.routePath,
          builder: (context, params) => const _salazarTienda('Administración'),
        ),
        FFRoute(
          name: IniciarSesionWidget.routeName,
          path: IniciarSesionWidget.routePath,
          builder: (context, params) => const _salazarAcceso('Iniciar sesión'),
        ),
        FFRoute(
          name: RegistroWidget.routeName,
          path: RegistroWidget.routePath,
          builder: (context, params) => const _salazarAcceso('Crear cuenta'),
        ),
        FFRoute(
          name: RecuperarContrasenaWidget.routeName,
          path: RecuperarContrasenaWidget.routePath,
          builder: (context, params) => const _salazarAcceso('Recuperar contraseña'),
        ),
        FFRoute(
          name: CatLogoCopyWidget.routeName,
          path: CatLogoCopyWidget.routePath,
          builder: (context, params) => const _salazarTienda('Catálogo'),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );
