# Catálogo e inventario transaccional para Perfumes Salazar

SC-703 · Grupo G04 · Universidad Fidélitas · Noviembre de 2026

## Resumen

Se desarrolló una aplicación web de perfumería que conserva la solicitud del cliente desde la selección de una fragancia hasta su atención por la tienda. La interfaz procede de una exportación de FlutterFlow. Firebase Authentication identifica al cliente y Firestore conserva el catálogo, el carrito y el historial. En Firebase Emulator Suite se verificó que dos compradores no pudieran reservar las mismas últimas unidades y que cancelar una solicitud pendiente restituyera las existencias. La evaluación cubre la implementación y sus datos de demostración. Quedan por medir su desempeño con compradores reales y la operación del servicio publicado.

## Problema y objetivo

En un pedido por mensajería, el cliente puede consultar un precio en el catálogo y descubrir, al escribir a la tienda, que la presentación ya se agotó. El objetivo fue vincular la consulta del catálogo con una reserva de inventario, de manera que cliente y personal pudieran recuperar el mismo pedido y seguir sus cambios de estado.

## Método y oferta de mercado

Se revisaron las funciones visibles de tres ofertas costarricenses y se contrastaron con las 29 historias del Avance 2. La selección intencional permite comparar recorridos de compra. No permite estimar participación de mercado, ingresos ni intención de compra.

| Oferta | Observación consignada en el avance | Decisión de diseño |
|---|---|---|
| Pura Esencia | Catálogo y consultas por WhatsApp | Compartir la referencia del pedido con la consulta. |
| Casa Aroma | Clasificación de productos y filtros de precio | Mostrar categoría, marca y orden por precio. |
| Soluna Perfumería | El carrito continúa en WhatsApp | Registrar la solicitud y mantener su historial antes del contacto. |

## Implementación

La navegación conserva las secciones de inicio, catálogo, favoritos, carrito y perfil del prototipo. El visitante puede buscar por nombre, marca o aroma. Al seleccionar un perfume ve las notas olfativas, la presentación en mililitros, el precio en colones y la cantidad disponible. Las operaciones personales requieren una sesión. El rol que figura en el perfil controla el panel administrativo y las reglas de Firestore aplican los permisos sobre los documentos.

El modelo utiliza ocho colecciones raíz: products, presentaciones, categorias, marcas, promociones, users, pedidos y movimientos_inventario. Favoritos y carrito son subcolecciones privadas. La interfaz reutiliza tres widgets personalizados para las existencias, las notas olfativas y el estado del pedido. Cinco funciones calculan el subtotal y el descuento, dan formato a los colones, comprueban cantidades y realizan búsquedas que toleran acentos y mayúsculas.

Dos funciones HTTPS ejecutan la creación y la cancelación del pedido. Al crear, el servidor vuelve a leer los precios, las existencias y la promoción, compara el total con el aceptado por el cliente y registra la reserva junto al pedido en una transacción. Un identificador permite reconocer reintentos. La cancelación de un pedido pendiente crea un movimiento de devolución y restituye las unidades.

## Resultados

| Comprobación | Resultado observado |
|---|---|
| Compilación y catálogo | Flutter 3.50 compiló las versiones de demostración y producción. En Test Mode de FlutterFlow se observaron fotos, precios y existencias en el simulador móvil. |
| Bienvenida e idioma | Dos pruebas de interfaz pasaron: navegación como invitado a 320 × 480 y restauración de la preferencia de idioma. |
| Permisos | El emulador permitió consultar el catálogo público y aplicó las restricciones de cliente y administrador en datos privados. |
| Precio y cupón | En el navegador local se pidió un Chanel N°5 de 100 ml. BIENVENIDA10 redujo el precio de ₡79 500 a ₡71 550 y el historial guardó ese total. La prueba de integración también rechazó un precio desactualizado. |
| Reintento y concurrencia | Un reintento no duplicó la compra. Dos solicitudes simultáneas por el último stock no produjeron una doble reserva. |
| Cancelación y seguimiento | La cancelación pendiente repuso inventario. Tras avanzar al estado entregado, el servicio rechazó la cancelación. |

## Alcance y conclusión

El recorrido probado permite demostrar que un pedido y sus movimientos de inventario permanecen consistentes frente a cambios de precio, reintentos y solicitudes concurrentes. La evaluación corresponde a emuladores locales. El acceso real con Google, el despliegue productivo de los servicios y la validación directa con el negocio requieren evidencias adicionales. Como siguiente evaluación de campo, conviene observar si un comprador logra encontrar su presentación, enviar la solicitud y consultar su estado sin asistencia.

## Fuentes

- [Pura Esencia](https://www.puraesenciacr.com/), [Casa Aroma](https://www.casaaromacr.com/tienda/) y [Soluna Perfumería](https://solunafragrance.com/). Revisión documental del proyecto, 19 de noviembre de 2026.
- [Transacciones y escrituras en lotes de Cloud Firestore](https://firebase.google.com/docs/firestore/manage-data/transactions). Documentación técnica.
- Prototipo de Perfumes Salazar y documentos de los avances 1 y 2, grupo G04.

## Recorrido para la defensa

1. Abrir el problema y explicar qué ocurre si dos personas eligen la última unidad.
2. Mostrar la comparación de mercado y relacionarla con el catálogo y el contacto por mensajería.
3. Recorrer catálogo, detalle, carrito y confirmación. Aplicar BIENVENIDA10 al Chanel de 100 ml con precio de ₡79 500 y comprobar el total de ₡71 550.
4. Abrir el pedido desde el perfil, cancelarlo y verificar la reposición. Cambiar al perfil administrador para mostrar los estados y el control de acceso.
5. Mostrar los resultados de las pruebas, identificar dónde se ejecutaron y cerrar con la validación pendiente con clientes reales.
