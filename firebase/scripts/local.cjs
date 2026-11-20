// Estos comandos solo trabajan en el proyecto local de demostración.
const {createRequire} = require('node:module');
const {join} = require('node:path');
const dependencias = createRequire(join(__dirname, '../functions/package.json'));
const {initializeApp} = dependencias('firebase-admin/app');
const {getFirestore, Timestamp, FieldValue} = dependencias('firebase-admin/firestore');
const {getAuth} = dependencias('firebase-admin/auth');

const proyecto = 'demo-perfumes';
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8085';
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';
initializeApp({projectId: proyecto});
const db = getFirestore();
const auth = getAuth();
const baseAuth = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1';

async function entrar(email, password) {
  const respuesta = await fetch(baseAuth + '/accounts:signInWithPassword?key=demo-perfumes', {
    method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({email, password, returnSecureToken: true}),
  });
  if (!respuesta.ok) throw new Error('No se pudo iniciar la sesión de prueba.');
  return (await respuesta.json()).idToken;
}

async function cuenta(uid, nombre, rol, password) {
  const email = uid + '@example.test';
  try {
    await auth.createUser({uid, email, password, displayName: nombre});
  } catch (error) {
    if (error.code !== 'auth/uid-already-exists' && error.code !== 'auth/email-already-exists') throw error;
  }
  const ref = db.collection('users').doc(uid);
  if (!(await ref.get()).exists) {
    await ref.create({uid, email, display_name: nombre, role: rol, created_time: FieldValue.serverTimestamp()});
  }
  return entrar(email, password);
}

async function llamar(funcion, datos, token) {
  const respuesta = await fetch('http://127.0.0.1:5001/' + proyecto + '/us-central1/' + funcion, {
    method: 'POST', headers: {'Content-Type':'application/json', ...(token && {Authorization:'Bearer ' + token})},
    body: JSON.stringify({data: datos}),
  });
  return {status: respuesta.status, ...(await respuesta.json())};
}
module.exports = {proyecto, db, auth, Timestamp, FieldValue, cuenta, entrar, llamar};
