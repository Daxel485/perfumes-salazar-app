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
        !cantidadDisponible(cantidad, unidadesDisponibles(v)) ||
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
  String codigo = '', errorCupon = '';
  String? entrega, pago;
  final direccion = TextEditingController();
  bool direccionEditada = false, inicializado = false;
  Datos? recibo;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (inicializado) return;
    inicializado = true;
    codigo = GoRouterState.of(context).uri.queryParameters['cupon'] ?? '';
    cupon.text = codigo;
    if (widget.confirmar)
      ejecutar(context, () async {
        final datos = (await perfil.get()).data();
        if (mounted && !direccionEditada)
          direccion.text = datos?['direccion'] as String? ?? '';
      });
  }

  Future<void> quitar(Ficha linea) async {
    if (await confirmarAccion(context, '¿Quitar este artículo del carrito?')) {
      await linea.reference.delete();
    }
  }

  @override
  void dispose() {
    direccion.dispose();
    cupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pedido = recibo;
    if (pedido != null)
      return ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Icon(Icons.check_circle_outline, size: 56),
          const Etiqueta('Pedido enviado'),
          SelectableText('Número de pedido: ${pedido['pedidoId']}'),
          for (final linea in pedido['resumen']) Text(linea),
          Text('Entrega: ${pedido['entrega']} · Pago: ${pedido['pago']}'),
          if (pedido['entrega'] == 'domicilio') Text(pedido['direccion']),
          Text('Subtotal: ${formatoColones(pedido['subtotal'])}'),
          Text('Descuento: ${formatoColones(pedido['descuento'])}'),
          Text('Total: ${formatoColones(pedido['total'])}'),
          FilledButton(
            onPressed: () => context.go('/misPedidos'),
            child: const Etiqueta('Ver mis pedidos'),
          ),
          TextButton(
            onPressed: () => context.go('/catLogo'),
            child: const Etiqueta('Seguir comprando'),
          ),
        ],
      );
    return Resultados(perfil.collection('carrito'), (lineas) {
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
              int subtotalElegible(Ficha? oferta) => oferta == null
                  ? 0
                  : lineas.fold<int>(0, (total, l) {
                      final v = vs[l.id];
                      if (v == null ||
                          !aplicaProducto(oferta.data(), v['producto_id']))
                        return total;
                      return total +
                          calcularSubtotal(
                            entero(v['precio']),
                            entero(l.data()['cantidad']),
                          );
                    });
              final baseDescuento = subtotalElegible(promo);
              final descuento = calcularDescuento(
                baseDescuento,
                entero(promo?.data()['porcentaje']),
              );
              final disponibles = lineas.every(
                (l) =>
                    ps.containsKey(vs[l.id]?['producto_id']) &&
                    cantidadDisponible(
                      entero(l.data()['cantidad']),
                      unidadesDisponibles(vs[l.id]),
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
                            Text(
                              'Subtotal: ${formatoColones(calcularSubtotal(entero(vs[l.id]?['precio']), entero(l.data()['cantidad'])))}',
                            ),
                            if (!widget.confirmar)
                              Wrap(
                                children: [
                                  IconButton(
                                    tooltip: traducir(context, 'Disminuir'),
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => ejecutar(
                                      context,
                                      () async {
                                        if (entero(l.data()['cantidad']) == 1) {
                                          await quitar(l);
                                        } else {
                                          await cambiarCantidad(
                                            db
                                                .collection('presentaciones')
                                                .doc(l.id),
                                            -1,
                                          );
                                        }
                                      },
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
                                        ejecutar(context, () => quitar(l)),
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
                  ...[
                    TextField(
                      controller: cupon,
                      decoration: InputDecoration(
                        labelText: traducir(context, 'Código de promoción'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final nuevo = cupon.text.trim().toUpperCase();
                        final oferta = promos
                            .where((p) => p.id == nuevo && vigente(p.data()))
                            .firstOrNull;
                        setState(() {
                          if (nuevo.isEmpty) {
                            codigo = '';
                            errorCupon = '';
                          } else if (oferta == null ||
                              subtotalElegible(oferta) == 0) {
                            errorCupon = oferta == null
                                ? 'Código no válido'
                                : 'El código no aplica a estos productos.';
                          } else {
                            codigo = nuevo;
                            errorCupon = '';
                          }
                        });
                      },
                      child: const Etiqueta('Aplicar código'),
                    ),
                    if (codigo.isNotEmpty) Text('Código aplicado: $codigo'),
                    if (errorCupon.isNotEmpty) Text(errorCupon),
                    if (codigo.isNotEmpty && baseDescuento == 0)
                      const Text('Revisa o quita el cupón aplicado.'),
                  ],
                  if (widget.confirmar) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Entrega'),
                      value: entrega,
                      items: const [
                        DropdownMenuItem(
                          value: 'domicilio',
                          child: Text('Envío a domicilio'),
                        ),
                        DropdownMenuItem(
                          value: 'retiro',
                          child: Text('Retiro en tienda'),
                        ),
                      ],
                      onChanged:
                          enviando ? null : (v) => setState(() => entrega = v),
                    ),
                    if (entrega == 'domicilio')
                      TextField(
                        controller: direccion,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Dirección de entrega',
                        ),
                        onChanged: (_) => direccionEditada = true,
                      ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Método de pago',
                      ),
                      value: pago,
                      items: const [
                        DropdownMenuItem(
                          value: 'sinpe',
                          child: Text('SINPE Móvil'),
                        ),
                        DropdownMenuItem(
                          value: 'efectivo',
                          child: Text('Efectivo'),
                        ),
                      ],
                      onChanged:
                          enviando ? null : (v) => setState(() => pago = v),
                    ),
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
                            (codigo.isNotEmpty && baseDescuento == 0)
                        ? null
                        : () => ejecutar(context, () async {
                              if (!widget.confirmar) {
                                context.push(
                                  Uri(
                                    path: '/confirmarPedido',
                                    queryParameters: codigo.isEmpty
                                        ? null
                                        : {'cupon': codigo},
                                  ).toString(),
                                );
                                return;
                              }
                              if (enviando) return;
                              if (entrega == null || pago == null)
                                throw StateError(
                                  'Elige la entrega y la forma de pago.',
                                );
                              final destino = entrega == 'domicilio'
                                  ? direccion.text.trim()
                                  : '';
                              if (entrega == 'domicilio' && destino.isEmpty)
                                throw StateError(
                                  'Agrega una dirección de entrega.',
                                );
                              final resumen = [
                                for (final l in lineas)
                                  '${ps[vs[l.id]?['producto_id']]?['nombre']} · ${vs[l.id]?['ml']} ml × ${l.data()['cantidad']}',
                              ];

                              setState(() => enviando = true);
                              try {
                                final firma = jsonEncode([
                                  cliente!.uid,
                                  codigo,
                                  entrega,
                                  pago,
                                  destino,
                                  subtotal - descuento,
                                  for (final l in lineas)
                                    [l.id, l.data()['cantidad']],
                                ]);
                                if (firma != firmaSolicitud) {
                                  firmaSolicitud = firma;
                                  solicitudPendiente =
                                      db.collection('pedidos').doc().id;
                                }
                                final solicitud = solicitudPendiente!;
                                final resultado = await llamar('crearPedido', {
                                  'versionCompra': 2,
                                  'entrega': entrega,
                                  'pago': pago,
                                  'direccion': destino,
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
                                if (mounted)
                                  setState(
                                    () => recibo = {
                                      ...resultado,
                                      'resumen': resumen,
                                      'subtotal': subtotal,
                                      'descuento': descuento,
                                      'entrega': entrega,
                                      'pago': pago == 'sinpe'
                                          ? 'SINPE Móvil'
                                          : 'Efectivo',
                                      'direccion': destino,
                                    },
                                  );
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
}

String fechaPedido(dynamic value) {
  if (value is! Timestamp) return 'Fecha sin registrar';
  final fecha = value.toDate().toLocal();
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} ${dos(fecha.hour)}:${dos(fecha.minute)}';
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
      lista = [...lista]..sort((a, b) {
          final pa = a.data()['estado'] == 'pendiente',
              pb = b.data()['estado'] == 'pendiente';
          if (admin && pa != pb) return pa ? -1 : 1;
          return entero(
            (b.data()['created_time'] as Timestamp?)?.millisecondsSinceEpoch,
          ).compareTo(
            entero(
              (a.data()['created_time'] as Timestamp?)?.millisecondsSinceEpoch,
            ),
          );
        });
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EstadoPedido(estado: '${p.data()['estado']}'),
                    Text(fechaPedido(p.data()['created_time'])),
                    Text('Total: ${formatoColones(entero(p.data()['total']))}'),
                    if (admin)
                      Text(
                        'Cliente: ${p.data()['cliente_nombre'] ?? (p.data()['user_ref'] as DocumentReference?)?.id ?? '—'}',
                      ),
                  ],
                ),
                children: [
                  if (p.data()['entrega'] != null)
                    Text(
                      'Entrega: ${p.data()['entrega']} · Pago: ${p.data()['pago'] == 'sinpe' ? 'SINPE Móvil' : p.data()['pago']}',
                    ),
                  if ((p.data()['direccion'] ?? '') != '')
                    Text('Dirección: ${p.data()['direccion']}'),
                  for (final estado in [
                    'pendiente',
                    'confirmado',
                    'en_preparacion',
                    'entregado',
                    'cancelado',
                  ])
                    if (p.data()['seguimiento']?[estado] is Timestamp)
                      Text(
                        '${estado.replaceAll('_', ' ')} · ${fechaPedido(p.data()['seguimiento'][estado])}',
                      ),
                  for (final item in p.data()['items'] ?? [])
                    ListTile(
                      title: Etiqueta('${item['nombre']} · ${item['ml']} ml'),
                      subtitle: Etiqueta(
                        'Cantidad: ${item['cantidad']} · Precio: ${formatoColones(entero(item['precio_unitario']))}',
                      ),
                    ),
                  Etiqueta(
                    'Total: ${formatoColones(entero(p.data()['total']))}',
                  ),
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
                      onPressed: () => ejecutar(context, () async {
                        await llamar('avanzarPedido', {
                          'pedidoId': p.id,
                          'estado': siguiente[p.data()['estado']],
                        });
                      }),
                      child: Etiqueta(
                        'Marcar como ${siguiente[p.data()['estado']]?.replaceAll('_', ' ')}',
                      ),
                    ),
                  TextButton(
                    onPressed: () => ejecutar(context, () async {
                      final numero = const String.fromEnvironment(
                        'WHATSAPP_COMERCIO',
                        defaultValue: '50689852121',
                      ).replaceAll(RegExp(r'[^0-9]'), '');
                      final url = Uri.https('wa.me', '/$numero', {
                        'text':
                            'Consulta sobre mi pedido de Perfumes Salazar: ${p.id}.',
                      });
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      )) {
                        if (!await launchUrl(url,
                            mode: LaunchMode.platformDefault))
                          throw StateError('No se pudo abrir WhatsApp.');
                      }
                    }),
                    child: const Etiqueta('Contactar a la tienda por WhatsApp'),
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
              Text(data['direccion'] ?? ''),
              ListTile(
                title: const Etiqueta('Editar información personal'),
                onTap: () => ejecutar(context, () async {
                  final nuevo = await formulario(
                      context,
                      'Mi perfil',
                      {
                        'display_name': 'Nombre',
                        'phone_number': 'Teléfono',
                        'direccion': 'Dirección de entrega',
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
                  onChanged: (v) => ejecutar(context, () => cambiarIdioma(v!)),
                ),
              ),
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
