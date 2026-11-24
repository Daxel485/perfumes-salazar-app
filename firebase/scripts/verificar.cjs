const assert = require('node:assert/strict');
const {randomUUID} = require('node:crypto');
const {proyecto,db,auth,cuenta,llamar} = require('./local.cjs');

async function verificar(){
  const prefijo = 'prueba-' + randomUUID().slice(0,8);
  const sku = prefijo + '-100';
  const producto = db.doc('products/' + prefijo);
  const variante = db.doc('presentaciones/' + sku);
  const usuario = prefijo+'-cliente', gerente=prefijo+'-admin';
  const linea = db.doc('users/' + usuario + '/carrito/' + sku);
  const perfil = db.doc('users/'+usuario);
  const raiz = 'projects/'+proyecto+'/databases/(default)/documents/';
  const limpiar = [producto,variante,linea,perfil, db.doc('users/'+gerente),db.doc('promociones/'+prefijo.toUpperCase())];
  async function firestore(metodo,path,token,fields){
    const resp=await fetch('http://127.0.0.1:8085/v1/'+raiz+path, {
      method: metodo, headers:{...(token && {Authorization:'Bearer '+token}),'Content-Type':'application/json'},
      ...(fields && {body:JSON.stringify({fields})}),
    });
    return resp.status;
  }
  try{
    const pass=randomUUID();
    const cliente=await cuenta(usuario,'Prueba','cliente',pass);
    const admin=await cuenta(gerente,'Prueba admin','admin',pass);
    const promo=prefijo.toUpperCase();
    await Promise.all([producto.set({nombre:'Producto de prueba',activo:true,precio:1000,stock:3}),variante.set({producto_id:prefijo,ml:100,precio:1000,stock:3,activa:true}),
      db.doc('promociones/'+promo).set({activa:true,porcentaje:10,inicio:new Date(Date.now()-60000),fin:new Date(Date.now()+86400000)})]);
    assert.equal(await firestore('GET',producto.path),200);
    assert.equal(await firestore('GET',perfil.path,cliente),200);
    assert.equal(await firestore('GET',perfil.path),403);
    assert.equal(await firestore('PATCH',producto.path+'?updateMask.fieldPaths=activo',cliente,{activo:{booleanValue:false}}),403);
    assert.equal(await firestore('PATCH',perfil.path+'?updateMask.fieldPaths=role',cliente,{role:{stringValue:'admin'}}),403);
    assert.equal(await firestore('PATCH',producto.path+'?updateMask.fieldPaths=nombre',admin,{nombre:{stringValue:'Fragancia de prueba'}}),200);
    const cantidad=2;
    const datos={solicitudId:prefijo,items:[{presentacionId:sku,cantidad}],desdeCarrito:true,totalEsperado:1800,codigo:promo};
    assert.equal((await llamar('crearPedido',datos)).status,401);
    assert.equal(await firestore('PATCH',linea.path,cliente,{cantidad:{integerValue:String(cantidad)},presentacion_ref:{referenceValue:raiz+variante.path}}),200);
    assert.equal((await llamar('crearPedido',{...datos,totalEsperado:1},cliente)).status,400);
    assert.equal((await producto.get()).get('stock'),3);
    const dos=await Promise.all([llamar('crearPedido',datos,cliente),llamar('crearPedido',datos,cliente)]);
    for(const r of dos) assert.equal(r.status,200,JSON.stringify(r));
    assert.equal(dos[0].result.pedidoId,dos[1].result.pedidoId);
    const ref=db.doc('pedidos/'+dos[0].result.pedidoId);
    limpiar.push(ref);
    const reserva=db.doc('movimientos_inventario/'+ref.id+'_reserva');
    const devolucion=db.doc('movimientos_inventario/'+ref.id+'_devolucion');
    limpiar.push(reserva,devolucion);
    assert.equal((await reserva.get()).get('lineas')[0].variacion,-cantidad);
    assert.equal(await firestore('GET',reserva.path,admin),200);
    assert.equal(await firestore('GET',reserva.path,cliente),403);
    const pedido=(await ref.get()).data();
    assert.equal(pedido.total,1800);assert.equal(pedido.descuento,200);assert.equal(pedido.items.length,1);
    for (const ref of [producto,variante]) {
      const inventario = (await ref.get()).data();
      assert.equal(inventario.stock,3);assert.equal(inventario.reservado,2);
    }
    assert.equal((await linea.get()).exists,false);
    assert.equal(await firestore('GET',ref.path,cliente),200);
    assert.equal(await firestore('GET',ref.path),403);
    assert.equal(await firestore('PATCH',ref.path+'?updateMask.fieldPaths=estado',cliente,{estado:{stringValue:'confirmado'}}),403);
    assert.equal((await llamar('cancelarPedido',{pedidoId:ref.id},admin)).status,404);
    for(let i=0;i<2;i++)assert.equal((await llamar('cancelarPedido',{pedidoId:ref.id},cliente)).status,200);
    assert.equal((await devolucion.get()).get('lineas')[0].variacion,cantidad);
    assert.equal((await variante.get()).get('stock'),3);assert.equal((await producto.get()).get('stock'),3);
    const competir=await Promise.all(['a','b'].map(s=>llamar('crearPedido',{solicitudId:prefijo+s,items:[{presentacionId:sku,cantidad:3}]},cliente)));
    assert.deepEqual(competir.map(r=>r.status).sort(),[200,400]);
    const ganador=db.doc('pedidos/'+competir.find(r=>r.status===200).result.pedidoId);
    limpiar.push(ganador,db.doc('movimientos_inventario/'+ganador.id+'_reserva'));
    assert.equal((await variante.get()).get('reservado'),3);
    for (const estado of ['confirmado','en_preparacion','entregado']) {
      assert.equal((await llamar('avanzarPedido',{pedidoId:ganador.id,estado},admin)).status,200);
    }
    limpiar.push(db.doc('movimientos_inventario/'+ganador.id+'_entrega'));
    assert.equal((await variante.get()).get('stock'),0);
    assert.equal((await variante.get()).get('reservado'),0);
    assert.equal((await llamar('cancelarPedido',{pedidoId:ganador.id},cliente)).status,400);
    console.log('OK · Catálogo público, roles, carrito privado, autenticación, cupón, precio, inventario, reintento, propiedad, cancelación, concurrencia y estados administrativos.');
  } finally {
    const lote=db.batch();for(const ref of limpiar)lote.delete(ref);await lote.commit();
    await Promise.all([usuario,gerente].map(uid=>auth.deleteUser(uid).catch(e=>{if(e.code!=='auth/user-not-found')throw e;})));
  }
}
verificar().catch(e=>{console.error(e);process.exitCode=1;});
