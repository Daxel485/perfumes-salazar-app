import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const entornoLocal = bool.fromEnvironment('EMULADORES');

Future initFirebase() async {
  if (kIsWeb) {
    if (entornoLocal) {
      await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: 'demo-perfumes', appId: '1:123456:web:demo',
        messagingSenderId: '123456', projectId: 'demo-perfumes',
        authDomain: 'localhost',
      ));
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8085);
      await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      return;
    }
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAZfkEEZQvxLVf6Gp88Hek1icMoNzlsHI0",
            authDomain: "perfumes-salazar-i0yn4x.firebaseapp.com",
            projectId: "perfumes-salazar-i0yn4x",
            storageBucket: "perfumes-salazar-i0yn4x.firebasestorage.app",
            messagingSenderId: "378049415009",
            appId: "1:378049415009:web:f73cce7d7c62d248172720"));
  } else {
    await Firebase.initializeApp();
  }
}
