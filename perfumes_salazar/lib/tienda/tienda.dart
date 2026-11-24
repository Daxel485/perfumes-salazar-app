import 'dart:convert';
import 'idioma.dart';
import '../backend/firebase/firebase_config.dart' show entornoLocal;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../custom_code/functions/catalogo.dart';
import '../custom_code/widgets/indicador_stock.dart';
import '../custom_code/widgets/notas_olfativas.dart';
import '../custom_code/widgets/estado_pedido.dart';

part 'compra.dart';
part 'administracion.dart';

typedef Datos = Map<String, dynamic>;
typedef Ficha = QueryDocumentSnapshot<Datos>;
final db = FirebaseFirestore.instance;
User? get cliente => FirebaseAuth.instance.currentUser;
DocumentReference<Datos> get perfil => db.collection('users').doc(cliente!.uid);
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

class Tienda extends StatefulWidget {
  const Tienda(this.seccion, {super.key});
  final String seccion;
  @override
  State<Tienda> createState() => _TiendaState();
}

class _TiendaState extends State<Tienda> {
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
                    db.collection('products').where('activo', isEqualTo: true),
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
        db.collection('products').where('activo', isEqualTo: true),
        (lista) => Resultados(
            db.collection('categorias').where('activa', isEqualTo: true),
            (catalogoCategorias) => Resultados(
                    db.collection('marcas').where('activa', isEqualTo: true),
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

class Detalle extends StatelessWidget {
  const Detalle(this.producto, {super.key});
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
                  db
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
        db.collection('promociones').where('activa', isEqualTo: true),
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
