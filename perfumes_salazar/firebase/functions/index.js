const {createHash} = require("node:crypto");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");

initializeApp();
const db = getFirestore();
const idValido = (valor) =>
  typeof valor === "string" && /^[a-zA-Z0-9_-]{1,80}$/.test(valor);

exports.crearPedido = onCall(async ({auth, data}) => {
  if (!auth) throw new HttpsError("unauthenticated", "Inicia sesión para pedir.");

  const {solicitudId, items, codigo} = data ?? {};
  if (!idValido(solicitudId) || !Array.isArray(items) ||
      items.length < 1 || items.length > 30 ||
      (codigo != null && !idValido(codigo))) {
    throw new HttpsError("invalid-argument", "Revisa los datos del pedido.");
  }

  const cantidades = new Map();
  for (const item of items) {
    if (!idValido(item?.presentacionId) || !Number.isInteger(item.cantidad) ||
        item.cantidad < 1 || item.cantidad > 99) {
      throw new HttpsError("invalid-argument", "Revisa las cantidades.");
    }
    const cantidad = (cantidades.get(item.presentacionId) ?? 0) + item.cantidad;
    if (cantidad > 99) {
      throw new HttpsError("invalid-argument", "Máximo 99 unidades por presentación.");
    }
    cantidades.set(item.presentacionId, cantidad);
  }

  const usuario = db.collection("users").doc(auth.uid);
  const pedidoId = createHash("sha256").update(JSON.stringify([auth.uid, solicitudId])).digest("hex");
  const pedido = db.collection("pedidos").doc(pedidoId);
  const lineas = [...cantidades].sort(([a], [b]) => a.localeCompare(b));
  const codigoNormalizado = codigo?.toUpperCase() ?? null;
  const contenido = JSON.stringify([lineas, codigoNormalizado]);

  return db.runTransaction(async (tx) => {
    const previo = await tx.get(pedido);
    if (previo.exists) {
      if (previo.get("contenido") !== contenido) {
        throw new HttpsError("already-exists", "Ya se usó ese identificador.");
      }
      return {pedidoId: pedido.id, total: previo.get("total")};
    }
    let carrito = [];
    if (data.desdeCarrito === true) {
      const actuales = await tx.get(usuario.collection("carrito"));
      carrito = actuales.docs;
      if (carrito.length !== cantidades.size ||
          carrito.some(doc => cantidades.get(doc.id) !== doc.get("cantidad"))) {
        throw new HttpsError("failed-precondition", "El carrito cambió. Revisa tu pedido.");
      }
    }

    const referencias = lineas.map(([id]) => db.collection("presentaciones").doc(id));
    const presentaciones = await tx.getAll(...referencias);
    const productos = new Map();
    const unidadesPorProducto = new Map();
    const detalle = [];
    let subtotal = 0;
    for (const [i, presentacion] of presentaciones.entries()) {
      const [, cantidad] = lineas[i];
      const p = presentacion.data();
      if (!p || !idValido(p.producto_id) || p.activa !== true ||
          !Number.isSafeInteger(p.stock) || p.stock < cantidad ||
          !Number.isSafeInteger(p.precio) || p.precio < 1 || p.precio > 10000000) {
        throw new HttpsError("failed-precondition", "Una presentación ya no está disponible.");
      }
      if (!productos.has(p.producto_id)) {
        productos.set(p.producto_id, await tx.get(db.collection("products").doc(p.producto_id)));
      }
      const producto = productos.get(p.producto_id);
      const unidades = (unidadesPorProducto.get(p.producto_id) ?? 0) + cantidad;
      if (producto.get("activo") !== true || !Number.isInteger(p.ml) || p.ml < 1 ||
          !Number.isSafeInteger(producto.get("stock")) || producto.get("stock") < unidades) {
        throw new HttpsError("failed-precondition", "Un perfume ya no está disponible.");
      }
      unidadesPorProducto.set(p.producto_id, unidades);
      detalle.push({
        producto_id: p.producto_id,
        nombre: producto.get("nombre") ?? "",
        presentacion_id: presentacion.id,
        ml: p.ml,
        cantidad,
        precio_unitario: p.precio,
      });
      subtotal += p.precio * cantidad;
    }

    let descuento = 0;
    if (codigoNormalizado) {
      const promo = await tx.get(db.collection("promociones").doc(codigoNormalizado));
      const ahora = Date.now();
      const porcentaje = promo.get("porcentaje");
      if (promo.get("activa") !== true ||
          !(promo.get("inicio")?.toMillis() <= ahora) ||
          !(promo.get("fin")?.toMillis() > ahora) ||
          !Number.isInteger(porcentaje) || porcentaje < 1 || porcentaje > 100) {
        throw new HttpsError("failed-precondition", "El código de promoción no está vigente.");
      }
      descuento = Math.round(subtotal * porcentaje / 100);
    }

    for (const [i, ref] of referencias.entries()) {
      tx.update(ref, {stock: FieldValue.increment(-lineas[i][1])});
    }
    for (const [id, unidades] of unidadesPorProducto) {
      tx.update(productos.get(id).ref, {stock: FieldValue.increment(-unidades)});
    }
    const total = subtotal - descuento;
    if (data.desdeCarrito === true && total !== data.totalEsperado) {
      throw new HttpsError("failed-precondition", "El precio cambió. Revisa el total.");
    }
    carrito.forEach(doc => tx.delete(doc.ref));
    tx.create(pedido, {
      user_ref: usuario,
      items: detalle,
      subtotal,
      descuento,
      total,
      codigo: codigoNormalizado,
      contenido,
      inventario_catalogo: true,
      estado: "pendiente",
      created_time: FieldValue.serverTimestamp(),
    });
    tx.create(db.collection("movimientos_inventario").doc(pedido.id + "_reserva"), {
      pedido_ref: pedido,
      tipo: "reserva",
      lineas: detalle.map(item => ({presentacion_id: item.presentacion_id,
        producto_id: item.producto_id, variacion: -item.cantidad})),
      created_time: FieldValue.serverTimestamp(),
    });
    return {pedidoId: pedido.id, total};
  });
});


exports.cancelarPedido = onCall(async ({auth, data}) => {
  if (!auth) throw new HttpsError("unauthenticated", "Inicia sesión para continuar.");
  const {pedidoId} = data ?? {};
  if (typeof pedidoId !== "string" || !/^[a-f0-9]{64}$/.test(pedidoId)) {
    throw new HttpsError("invalid-argument", "Identificador de pedido inválido.");
  }

  const usuario = db.collection("users").doc(auth.uid);
  const referencia = db.collection("pedidos").doc(pedidoId);
  return db.runTransaction(async (tx) => {
    const pedido = (await tx.get(referencia)).data();
    if (!pedido || !pedido.user_ref.isEqual(usuario)) {
      throw new HttpsError("not-found", "No se encontró el pedido.");
    }
    if (pedido.estado === "cancelado") return {pedidoId, estado: "cancelado"};
    if (pedido.estado !== "pendiente") {
      throw new HttpsError("failed-precondition", "Solo se cancelan pedidos pendientes.");
    }
    const unidadesPorProducto = new Map();
    for (const item of pedido.items) {
      const presentacion = db.collection("presentaciones").doc(item.presentacion_id);
      tx.update(presentacion, {stock: FieldValue.increment(item.cantidad)});
      unidadesPorProducto.set(item.producto_id,
        (unidadesPorProducto.get(item.producto_id) ?? 0) + item.cantidad);
    }
    if (pedido.inventario_catalogo === true) {
      for (const [id, unidades] of unidadesPorProducto) {
        tx.update(db.collection("products").doc(id), {stock: FieldValue.increment(unidades)});
      }
    }
    tx.update(referencia, {
      estado: "cancelado",
      cancelled_time: FieldValue.serverTimestamp(),
    });
    tx.create(db.collection("movimientos_inventario").doc(pedidoId + "_devolucion"), {
      pedido_ref: referencia,
      tipo: "devolucion",
      lineas: pedido.items.map(item => ({presentacion_id: item.presentacion_id,
        producto_id: item.producto_id, variacion: item.cantidad})),
      created_time: FieldValue.serverTimestamp(),
    });
    return {pedidoId, estado: "cancelado"};
  });
});
