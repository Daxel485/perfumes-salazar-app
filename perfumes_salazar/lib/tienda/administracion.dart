part of 'tienda.dart';

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
        db.collection('products'),
        (productos) => Resultados(
          db.collection('pedidos'),
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
        db.collection(grupo),
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
    final col = db.collection(grupo);
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
    await db.runTransaction((tx) async {
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
            db
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
    final ref = v?.reference ?? db.collection('presentaciones').doc();
    final stock = int.parse(valores['stock']!),
        precio = int.parse(valores['precio']!);
    await db.runTransaction((tx) async {
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
