part of 'tienda.dart';

Future<void> cambiarCantidad(
  DocumentReference<Datos> variante,
  int incremento,
) async {
  final linea = perfil.collection('carrito').doc(variante.id);
  await db.runTransaction((tx) async {
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
          db.collection('presentaciones').where('activa', isEqualTo: true),
          (variantes) => Resultados(
            db.collection('products').where('activo', isEqualTo: true),
            (productos) => Resultados(
              db.collection('promociones').where('activa', isEqualTo: true),
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
                                          db
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
                                          db
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
                                        db.collection('pedidos').doc().id;
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
    final todos = db.collection('pedidos');
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
