# Demostración local de Perfumes Salazar

La aplicación utiliza Firebase Authentication, Cloud Firestore y dos funciones HTTPS. Se puede evaluar el registro, catálogo, favoritos, carrito, promociones, solicitudes y panel administrativo con los emuladores locales. Los datos y cuentas de esta guía pertenecen al proyecto de prueba `demo-perfumes`.

## Iniciar

Se requieren Flutter 3.50, Node.js 22, Java 21 y Firebase CLI. Desde la raíz del repositorio, ejecutar en una terminal:

```powershell
npm ci --prefix firebase/functions
firebase emulators:start --config firebase/firebase.json --project demo-perfumes --only "auth,firestore,functions"
```

Cuando Firebase muestre que los emuladores están listos, abrir otra terminal en la raíz:

```powershell
node firebase/scripts/demostracion.cjs
cd perfumes_salazar
flutter pub get
flutter run -d chrome --dart-define=EMULADORES=true
```

El script de carga es repetible. Conserva los cambios al volver a ejecutarlo sobre la misma sesión. Los tres servicios emulados utilizan los puertos 9099 (Authentication), 8085 (Firestore) y 5001 (Functions).

| Acceso local | Correo | Contraseña de demostración |
|---|---|---|
| Cliente | cliente@example.test | Demostracion-2026 |
| Administración | administracion@example.test | Demostracion-2026 |

## Recorrido de compra

1. Entrar como invitado, buscar Chanel y revisar el precio, las notas y las unidades disponibles de la presentación de 100 ml.
2. Entrar como cliente, abrir Favoritos y Carrito. En la primera carga se prepara un Chanel N°5. La aplicación permite quitarlo o cambiar su cantidad.
3. Revisar el pedido, aplicar `BIENVENIDA10` y enviar. Para una unidad de ₡79 500 el total es ₡71 550. La transacción guarda los precios, aplica el descuento, rebaja existencias y vacía el carrito.
4. Consultar Mis pedidos. Cancelar un pedido pendiente y comprobar que las unidades vuelven a estar disponibles.
5. Entrar como administrador. En el perfil, abrir Panel de administración para editar productos, presentaciones, marcas, categorías y promociones. Marcar un pedido pendiente como confirmado, en preparación y entregado.

Firestore usa las colecciones raíz `products`, `presentaciones`, `categorias`, `marcas`, `promociones`, `users`, `pedidos` y `movimientos_inventario`, además de las subcolecciones privadas `favoritos` y `carrito` de cada cliente. El registro administrativo de inventario conserva la reserva o devolución de cada presentación en la misma transacción del pedido. Los cambios en el carrito se guardan por usuario. La colección `pedidos` mantiene el historial aunque luego cambie el catálogo.

## Comprobación automatizada

Con los tres emuladores en ejecución, ejecutar en la raíz:

```powershell
node firebase/scripts/verificar.cjs
```

La prueba crea datos aislados y los retira al terminar. Comprueba la lectura pública del catálogo, la privacidad de perfiles, las operaciones administrativas, el cupón y el precio aceptado, el reintento de un pedido, pedidos simultáneos por el último stock, la cancelación y el avance de estados. Google usa el flujo de identidad simulado por Firebase en este entorno. Una prueba con una cuenta real requiere el proveedor y el dominio autorizados en el proyecto publicado.


