# Demostración local de Perfumes Salazar

La aplicación utiliza Firebase Authentication, Cloud Firestore y tres funciones HTTPS. Se puede evaluar el registro, catálogo, favoritos, carrito, promociones, solicitudes y panel administrativo con los emuladores locales. Los datos y cuentas de esta guía pertenecen al proyecto de prueba `demo-perfumes`.

## Abrir el paquete de entrega en Windows

Extraer el ZIP en una carpeta y abrir `INICIAR-DEMO.cmd`. Se necesitan Node.js 22 con npm y Java 21 en el PATH. El primer inicio descarga Firebase CLI, las dependencias y los emuladores. El lanzador carga los datos de muestra y abre [Perfumes Salazar](http://127.0.0.1:8765/). Conservar la ventana abierta durante la demostración. La carpeta `demo-web` incluye la compilación para este entorno.

## Ejecutar desde el código fuente

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
3. En Perfil, guardar una dirección. En Inicio, «Ver promoción» abre el catálogo con los perfumes participantes. Agregar Chanel y Sauvage al carrito y aplicar BIENVENIDA10. La promoción de muestra descuenta un 10 % únicamente de Chanel. Un código vencido muestra «Código no válido» y conserva el total anterior.
4. En «Revisar pedido», seleccionar domicilio o retiro y SINPE Móvil o efectivo. Con domicilio, revisar la dirección precargada. Enviar y comprobar el número de pedido, el resumen y el acceso al historial. Desde el detalle, WhatsApp abre una consulta con la referencia del pedido.
5. En Administración → Pedidos, avanzar de pendiente a confirmado, en preparación y entregado. En un pedido distinto, cancelar mientras sigue pendiente. Durante la reserva, las unidades disponibles son stock menos reservado. La entrega descuenta el stock físico y libera la reserva. La cancelación solo libera la reserva. Las promociones anteriores que carecen del campo producto_ids mantienen el alcance general hasta que se edita su selección.

Firestore usa las colecciones raíz `products`, `presentaciones`, `categorias`, `marcas`, `promociones`, `users`, `pedidos` y `movimientos_inventario`, además de las subcolecciones privadas `favoritos` y `carrito` de cada cliente. El registro administrativo de inventario conserva la reserva o devolución de cada presentación en la misma transacción del pedido. Los cambios en el carrito se guardan por usuario. La colección `pedidos` mantiene el historial aunque luego cambie el catálogo.

## Comprobación automatizada

Con los tres emuladores en ejecución, ejecutar en la raíz:

```powershell
node firebase/scripts/probar_compra.cjs
node firebase/scripts/verificar.cjs
```

La prueba crea datos aislados y los retira al terminar. Comprueba la lectura pública del catálogo, la privacidad de perfiles, las operaciones administrativas, el cupón y el precio aceptado, el reintento de un pedido, pedidos simultáneos por el último stock, la cancelación y el avance de estados. Google usa el flujo de identidad simulado por Firebase en este entorno. Una prueba con una cuenta real requiere el proveedor y el dominio autorizados en el proyecto publicado.


