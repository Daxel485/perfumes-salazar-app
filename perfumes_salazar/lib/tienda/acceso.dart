import 'idioma.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../backend/backend.dart' show maybeCreateUser;
import 'tienda.dart' show tinta, crema;

class Acceso extends StatefulWidget {
  const Acceso(this.modo, {super.key});
  final String modo;
  @override
  State<Acceso> createState() => _AccesoState();
}

class _AccesoState extends State<Acceso> {
  final form = GlobalKey<FormState>();
  final correo = TextEditingController(), clave = TextEditingController();
  bool ocupado = false, ocultar = true;
  String mensaje = '';
  @override
  void dispose() {
    correo.dispose();
    clave.dispose();
    super.dispose();
  }

  Future<void> enviar({bool google = false}) async {
    if (ocupado || (!google && !form.currentState!.validate())) return;
    setState(() {
      ocupado = true;
      mensaje = '';
    });
    try {
      final auth = FirebaseAuth.instance;
      await auth.setLanguageCode(idiomaApp.value.languageCode);
      if (widget.modo == 'Recuperar contraseña' && !google) {
        await auth.sendPasswordResetEmail(email: correo.text.trim());
        if (mounted)
          setState(
            () => mensaje =
                'Si tienes una cuenta, recibirás un enlace para restablecer tu contraseña.',
          );
        return;
      }
      final cred = google
          ? await auth.signInWithPopup(GoogleAuthProvider())
          : widget.modo == 'Crear cuenta'
              ? await auth.createUserWithEmailAndPassword(
                  email: correo.text.trim(),
                  password: clave.text,
                )
              : await auth.signInWithEmailAndPassword(
                  email: correo.text.trim(),
                  password: clave.text,
                );
      await maybeCreateUser(cred.user!);
      if (mounted) context.go('/inicio');
    } on FirebaseAuthException catch (e) {
      if (mounted)
        setState(
          () => mensaje = switch (e.code) {
            'email-already-in-use' => 'Ese correo ya tiene una cuenta.',
            'weak-password' => 'La contraseña es demasiado corta.',
            'popup-closed-by-user' => 'Se cerró el acceso con Google.',
            'network-request-failed' => 'Revisa tu conexión a Internet.',
            _ =>
              'No se pudo iniciar la operación. Revisa los datos e inténtalo de nuevo.',
          },
        );
    } catch (_) {
      if (mounted)
        setState(
          () => mensaje =
              'No se pudo cargar el perfil. Comprueba la conexión y los permisos.',
        );
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registro = widget.modo == 'Crear cuenta',
        recuperar = widget.modo == 'Recuperar contraseña';
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        title: const Etiqueta('Perfumes Salazar'),
        backgroundColor: tinta,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Etiqueta(
                    widget.modo,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: correo,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: traducir(context, 'Correo electrónico'),
                    ),
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : traducir(context, 'Ingresa un correo válido.'),
                  ),
                  if (!recuperar)
                    TextFormField(
                      controller: clave,
                      obscureText: ocultar,
                      decoration: InputDecoration(
                        labelText: traducir(context, 'Contraseña'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultar ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => ocultar = !ocultar),
                        ),
                      ),
                      validator: (v) => (v ?? '').length < (registro ? 8 : 1)
                          ? traducir(context, registro ? 'Usa al menos 8 caracteres.' : 'Revisa la contraseña.')
                          : null,
                    ),
                  if (registro)
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: traducir(context, 'Confirmar contraseña'),
                      ),
                      validator: (v) => v == clave.text
                          ? null
                          : traducir(context, 'Las contraseñas no coinciden.'),
                    ),
                  if (mensaje.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Etiqueta(mensaje),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: ocupado ? null : () => enviar(),
                    child: Etiqueta(recuperar ? 'Enviar enlace' : widget.modo),
                  ),
                  if (!recuperar)
                    OutlinedButton(
                      onPressed: ocupado ? null : () => enviar(google: true),
                      child: const Etiqueta('Continuar con Google'),
                    ),
                  if (!recuperar && !registro)
                    TextButton(
                      onPressed: () => context.push('/recuperarContrasena'),
                      child: const Etiqueta('Olvidé mi contraseña'),
                    ),
                  TextButton(
                    onPressed: () => context.go(
                      registro || recuperar ? '/iniciarSesion' : '/registro',
                    ),
                    child: Etiqueta(
                      registro || recuperar ? 'Iniciar sesión' : 'Crear cuenta',
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/catLogo'),
                    child: const Etiqueta('Explorar como invitado'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
