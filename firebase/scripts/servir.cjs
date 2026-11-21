const http = require('node:http');
const path = require('node:path');
const fs = require('node:fs');
const {pipeline} = require('node:stream');

const raiz = fs.realpathSync(process.argv[2]);
const indice = path.join(raiz, 'index.html');
if (!fs.existsSync(indice) || !fs.existsSync(path.join(raiz, 'main.dart.js'))) {
  throw Error('La carpeta indicada debe contener una compilación Flutter web.');
}
const tipos = {
  '.html':'text/html; charset=utf-8', '.js':'text/javascript; charset=utf-8',
  '.mjs':'text/javascript; charset=utf-8', '.wasm':'application/wasm',
  '.json':'application/json; charset=utf-8', '.css':'text/css; charset=utf-8',
  '.png':'image/png', '.jpg':'image/jpeg', '.jpeg':'image/jpeg', '.svg':'image/svg+xml',
  '.webp':'image/webp', '.ico':'image/x-icon', '.otf':'font/otf', '.ttf':'font/ttf',
  '.woff':'font/woff', '.woff2':'font/woff2',
};
const servidor = http.createServer(async (req,res) => {
  if (!['GET','HEAD'].includes(req.method)) {res.writeHead(405,{Allow:'GET, HEAD'}).end();return;}
  try {
    const ruta = decodeURIComponent(new URL(req.url,'http://127.0.0.1').pathname);
    if (ruta.includes('\\') || ruta.includes('\0') || ruta.includes(':')) {res.writeHead(400).end();return;}
    let archivo = path.resolve(raiz,'.'+ruta);
    const relativa = path.relative(raiz,archivo);
    if (relativa.startsWith('..') || path.isAbsolute(relativa)) {res.writeHead(403).end();return;}
    if (ruta==='/' || !path.extname(ruta) && (req.headers.accept || '').includes('text/html')) archivo=indice;
    const real=await fs.promises.realpath(archivo);
    if (path.relative(raiz,real).startsWith('..')) {res.writeHead(403).end();return;}
    const stat = await fs.promises.stat(real);
    if (!stat.isFile()) {res.writeHead(404).end();return;}
    res.writeHead(200,{'Content-Type':tipos[path.extname(real)] || 'application/octet-stream',
      'Content-Length':stat.size,'Cache-Control':'no-cache','X-Content-Type-Options':'nosniff'});
    if (req.method==='HEAD') {res.end();return;}
    pipeline(fs.createReadStream(real),res,()=>{});
  } catch(e) {res.writeHead(e.code==='ENOENT' ? 404 : 400).end();}
});
servidor.on('error', e=>{console.error('No se pudo abrir el servidor local:', e.message);process.exitCode=1;});
servidor.listen(8765,'127.0.0.1',()=>console.log('Perfumes Salazar · http://127.0.0.1:8765/'));
