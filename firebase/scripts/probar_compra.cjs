const assert = require('node:assert/strict');
const {randomUUID} = require('node:crypto');
const {db, Timestamp, entrar, llamar} = require('./local.cjs');

async function probarCompra() {
  const id = 'compra-' + randomUUID().slice(0, 8);
  const cliente = await entrar('cliente@example.test', 'Demostracion-2026');
  const admin = await entrar('administracion@example.test', 'Demostracion-2026');
  const sku = sufijo => `${id}-${sufijo}`;
  const a = sku('a'), b = sku('b');
  const cupon = id.toUpperCase(), vencido = cupon + '-FIN';
  const precio = [1000, 2000];
  const referencias = [];
  const guardar = async (path, datos) => {
    const ref = db.doc(path);
    referencias.push(ref);
    await ref.create(datos);
  };
  const inventario = async (stock, reservado) => {
    for (const key of [a,b]) {
      for (const coleccion of ['products','presentaciones']) {
        const datos = (await db.doc(`${coleccion}/${key}`).get()).data();
        assert.equal(datos.stock,stock); assert.equal(datos.reservado ?? 0,reservado);
      }
    }
  };
  try {
    for (const [pos,key] of [a,b].entries()) {
      await guardar(`products/${key}`, {nombre:key, activo:true, stock:4, precio:precio[pos]});
      await guardar(`presentaciones/${key}`, {producto_id:key, activa:true, ml:100, stock:4, precio:precio[pos]});
    }
    for (const [codigo,fin] of [[cupon,86400000],[vencido,-1000]]) {
      await guardar('promociones/'+codigo, {producto_ids:[a],activa:true,porcentaje:10,
        inicio:Timestamp.fromMillis(Date.now()-86400000),fin:Timestamp.fromMillis(Date.now()+fin)});
    }
    const solicitud = {versionCompra:2,entrega:'domicilio',pago:'sinpe',direccion:'Dirección de prueba',
      items:[a,b].map(presentacionId=>({presentacionId,cantidad:1})),codigo:cupon,solicitudId:id};
    assert.equal((await llamar('crearPedido',{...solicitud,codigo:vencido},cliente)).status,400);
    assert.equal((await llamar('crearPedido',{...solicitud,direccion:''},cliente)).status,400);
    await inventario(4,0);
    for (const entregar of [false,true]) {
      const datos = entregar ? {...solicitud,solicitudId:id+'-ret',entrega:'retiro',pago:'efectivo',direccion:''} : solicitud;
      const respuesta = await llamar('crearPedido',datos,cliente);
      assert.equal(respuesta.status,200,JSON.stringify(respuesta));
      const pedidoId=respuesta.result.pedidoId;
      const ref=db.doc('pedidos/'+pedidoId);
      referencias.push(ref,db.doc('movimientos_inventario/'+pedidoId+'_reserva'));
      const pedido=(await ref.get()).data();
      assert.deepEqual([pedido.subtotal,pedido.descuento,pedido.total],[3000,100,2900]);
      assert.deepEqual([pedido.entrega,pedido.pago,pedido.direccion],[datos.entrega,datos.pago,datos.direccion]);
      assert.equal((await llamar('crearPedido',datos,cliente)).result.pedidoId,pedidoId);
      await inventario(4,1);
      if (entregar) {
        for (const estado of ['confirmado','en_preparacion','entregado','entregado']) {
          assert.equal((await llamar('avanzarPedido',{pedidoId,estado},admin)).status,200);
        }
        const final=(await ref.get()).data();
        assert.deepEqual(Object.keys(final.seguimiento).sort(),['confirmado','en_preparacion','entregado','pendiente']);
        referencias.push(db.doc('movimientos_inventario/'+pedidoId+'_entrega'));
        await inventario(3,0);
      } else {
        for (let intento=0;intento<2;intento++) assert.equal((await llamar('cancelarPedido',{pedidoId},cliente)).status,200);
        referencias.push(db.doc('movimientos_inventario/'+pedidoId+'_devolucion'));
        await inventario(4,0);
      }
    }
    console.log('OK · Carrito mixto ₡3.000 → ₡2.900, cupón vencido, dirección requerida, retiro/efectivo, domicilio/SINPE, reserva, cancelación y entrega idempotentes.');
  } finally {
    const batch=db.batch(); for(const ref of referencias) batch.delete(ref); await batch.commit();
  }
}
probarCompra().catch(error=>{console.error(error.message);process.exitCode=1;});
