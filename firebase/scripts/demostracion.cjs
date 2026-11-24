const {db, Timestamp, cuenta, llamar, FieldValue} = require('./local.cjs');
const pass = 'Demostracion-2026';

const perfumes = [
  ['sauvage','Sauvage Eau de Parfum','Dior','Hombre','Amaderado especiado','Bergamota, pimienta y ambroxan',68500,7,'3/3b/Dior_Sauvage_Verpackung.jpg'],
  ['chanel-5','Chanel N°5','Chanel','Mujer','Floral aldehídico','Aldehídos, jazmín y rosa',79500,4,'7/7c/CHANEL_N%C2%B05.jpg'],
  ['black-opium','Black Opium','Yves Saint Laurent','Mujer','Oriental vainilla','Café, vainilla y flores blancas',73500,0,'e/e8/Black_opium.jpg'],
];

async function iniciar() {
  const cliente = await cuenta('cliente','Cliente de demostración','cliente',pass);
  await cuenta('administracion','Administración de demostración','admin',pass);
  await db.runTransaction(async tx => {
    // Crear solo una vez. Volver a iniciar conserva cambios y pedidos de la demostración.
    const inicio = db.doc('configuracion/demostracion');
    if ((await tx.get(inicio)).exists) return;
    for (const [id,nombre,marca,categoria,aroma,notas,precio,stock,archivo] of perfumes) {
      tx.create(db.doc('products/' + id), {
        nombre,marca,categoria,aroma,notas,precio,stock,activo:true,
        descripcion: nombre + ' presenta un perfil ' + aroma.toLowerCase() + '. Sus notas principales son ' + notas.toLowerCase() + '.',
        imagen:'https://upload.wikimedia.org/wikipedia/commons/' + archivo,
      });
      tx.create(db.doc('presentaciones/' + id + '-100'), {producto_id:id,ml:100,precio,stock,activa:true});
    }
    for (const [coleccion, valores] of [['categorias',['Hombre','Mujer']],['marcas',['Dior','Chanel','Yves Saint Laurent']]]) {
      for (const nombre of valores) tx.create(db.collection(coleccion).doc(nombre.toLowerCase().replaceAll(' ','-')), {nombre,activa:true});
    }
    tx.create(db.doc('promociones/BIENVENIDA10'),{codigo:'BIENVENIDA10',porcentaje:10,activa:true,inicio:Timestamp.fromMillis(Date.now()-86400000),fin:Timestamp.fromMillis(Date.now()+365*86400000)});
    tx.create(db.doc('users/cliente/favoritos/sauvage'),{producto_ref:db.doc('products/sauvage'),created_time:FieldValue.serverTimestamp()});
    tx.create(db.doc('users/cliente/carrito/chanel-5-100'),{presentacion_ref:db.doc('presentaciones/chanel-5-100'),cantidad:1});
    tx.create(inicio,{cargado:FieldValue.serverTimestamp()});
  });
  const pedido = await llamar('crearPedido',{solicitudId:'muestra-sauvage',items:[{presentacionId:'sauvage-100',cantidad:1}]},cliente);
  if (pedido.status!==200) throw Error(JSON.stringify(pedido));
  const muestraCancelada = await llamar('crearPedido',{solicitudId:'muestra-cancelada',items:[{presentacionId:'chanel-5-100',cantidad:1}]},cliente);
  if(muestraCancelada.status!==200) throw Error(JSON.stringify(muestraCancelada));
  const cancelada = await llamar('cancelarPedido',{pedidoId:muestraCancelada.result.pedidoId},cliente);
  if(cancelada.status!==200) throw Error(JSON.stringify(cancelada));
  console.log('Catálogo y pedido de muestra disponibles en los emuladores de demo-perfumes.');
}
iniciar().catch(e=>{console.error(e.message);process.exitCode=1;});
