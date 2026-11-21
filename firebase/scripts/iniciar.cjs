const fs = require('node:fs');
const path = require('node:path');
const {spawn} = require('node:child_process');
const {once} = require('node:events');
const {setTimeout: esperar} = require('node:timers/promises');
const raiz = path.resolve(__dirname,'../..');
const firebase = path.join(raiz,'firebase');
const carpetaWeb = path.resolve(process.argv[2] || path.join(raiz,'demo-web'));
const hijos = new Set();

function proceso(programa, args, cwd=raiz) {
  const hijo=spawn(programa,args,{cwd,stdio:'inherit',windowsHide:true});
  hijos.add(hijo);
  const fin=once(hijo,'exit').then(([codigo])=>codigo);
  fin.catch(()=>{}).finally(()=>hijos.delete(hijo));
  return {hijo, fin};
}
function npm(args) {
  // La línea para cmd solo contiene opciones fijas de este archivo.
  if (process.platform==='win32') return proceso('cmd.exe',['/d','/c','npm.cmd '+args.join(' ')]);
  return proceso('npm',args);
}
async function comprobarServicio(url) {
  try {return (await fetch(url,{signal:AbortSignal.timeout(1800)})).ok;} catch {return false;}
}
async function iniciar() {
  if (Number(process.versions.node.split('.')[0])<22) throw Error('Se requiere Node.js 22 o posterior.');
  if (!fs.existsSync(path.join(carpetaWeb,'main.dart.js'))) {
    throw Error('Extrae el paquete completo. Debe incluir demo-web/main.dart.js junto a INICIAR-DEMO.cmd, o indica la carpeta de la compilación local como argumento.');
  }
  const web='http://127.0.0.1:8765/';
  const hub='http://127.0.0.1:4400/emulators';
  if (await comprobarServicio(hub) && await comprobarServicio(web+'version.json')) {
    const datos=await (await fetch(web+'version.json')).json();
    if(datos.package_name==='perfumes_salazar') {
      console.log('La demostración ya está en ejecución: '+web);
      if(process.platform==='win32') await proceso('cmd.exe',['/d','/c','start "" '+web]).fin;
      return;
    }
  }
  if(await comprobarServicio(hub) || await comprobarServicio(web)) {
    throw Error('Otro servicio usa los puertos de la demo. Cierra su terminal antes de volver a iniciar.');
  }
  if(!fs.existsSync(path.join(firebase,'functions/node_modules/firebase-admin'))) {
    const instalacion=npm(['ci','--prefix','firebase/functions','--no-audit','--no-fund']);
    if(await instalacion.fin!==0) throw Error('No se pudieron instalar las dependencias del backend.');
  }
  const opciones=['emulators:start','--only','auth,firestore,functions','--project','demo-perfumes','--config','firebase/firebase.json'];
  const backend=process.env.PERFUMES_FIREBASE_CLI
    ? proceso(process.execPath,[process.env.PERFUMES_FIREBASE_CLI,...opciones])
    : npm(['exec','--yes','--package=firebase-tools@15.37.0','--','firebase',...opciones]);
  // El hub se inicia antes que las funciones. Esperar las tres piezas antes de cargar el catálogo.
  let listo=false;
  for(let i=0;i<600;i++) {
    if(backend.hijo.exitCode!==null) throw Error('Firebase terminó antes de iniciar. Comprueba Java 21 y los puertos de la demo.');
    if (await comprobarServicio(hub)) {
      try {
        const resp=await fetch('http://127.0.0.1:5001/demo-perfumes/us-central1/crearPedido',{method:'POST',
          headers:{'Content-Type':'application/json'},body:JSON.stringify({data:{}}),signal:AbortSignal.timeout(3000)});
        if(resp.status===401){listo=true;break;}
      } catch {}
    }
    await esperar(1000);
  }
  if(!listo) throw Error('Firebase no terminó de iniciar en diez minutos.');
  if(await proceso(process.execPath,[path.join(__dirname,'demostracion.cjs')]).fin!==0) throw Error('No se pudieron cargar los datos de prueba.');
  const sitio=proceso(process.execPath,[path.join(__dirname,'servir.cjs'),carpetaWeb]);
  for(let i=0;i<30 && !await comprobarServicio(web+'version.json');i++) await esperar(200);
  if(!await comprobarServicio(web+'version.json'))throw Error('No se pudo iniciar el sitio web local.');
  console.log('Abre '+web+' y conserva esta ventana abierta durante la demostración. Para terminar, presiona Ctrl+C.');
  if(process.platform==='win32') proceso('cmd.exe',['/d','/c','start "" '+web]);
  await Promise.race([sitio.fin,backend.fin]);
}
iniciar().catch(e=>{console.error(e.message);process.exitCode=1;}).finally(()=>{
  for (const hijo of hijos) if(hijo.exitCode===null) hijo.kill();
});
