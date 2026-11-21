# Guía de evaluación final

## Entornos de la entrega

| Entorno | Estado comprobado |
|---|---|
| Demostración local | Aplicación web compilada con Flutter y servicios Firebase emulados. En el navegador se envió una solicitud con el cupón BIENVENIDA10. Las pruebas de integración comprueban roles, importes, concurrencia, cancelación y movimientos de inventario. [Cupón aplicado](evidencias/Cupon.jpg) · [Pedido registrado](evidencias/Pedido.jpg) |
| Firebase de producción | Reglas de Firestore publicadas en `perfumes-salazar-i0yn4x`. Los proveedores de autenticación habilitados son correo y contraseña y Google. |
| FlutterFlow Studio | El proyecto tiene guardado el `main.dart` personalizado. Test Mode compiló y mostró el catálogo con fotografías y cantidades. [Captura de FlutterFlow](evidencias/FlutterFlow.jpg) |
| Funciones de pedidos en producción | El despliegue de las funciones invocables `crearPedido` y `cancelarPedido` requiere el plan Blaze. El recorrido transaccional verificado se ejecuta en el emulador del ZIP. |

La primera ejecución del paquete requiere Internet, Windows, Node.js 22 con npm y JDK 21. El lanzador inicia los emuladores, carga las cuentas de demostración y abre la web. [Instrucciones de ejecución](../firebase/DEMOSTRACION.md) · [Requisitos de despliegue de Firebase](https://firebase.google.com/docs/functions/get-started#deploy_functions_to_a_production_environment)

## Evidencias para la rúbrica

| Criterio | Dónde comprobarlo |
|---|---|
| Almacenamiento | La demostración usa ocho colecciones raíz con documentos y dos subcolecciones privadas. La tabla de datos detalla su uso. |
| Autenticación y roles | Entrar con las cuentas locales de cliente y administración. La prueba de integración verifica que un cliente puede consultar su perfil y que solo administración puede editar productos o avanzar pedidos. En el emulador, Google usa una identidad simulada. |
| Tres widgets personalizados | La ficha muestra `NotasOlfativas` e `IndicadorStock`. El historial utiliza `EstadoPedido`. [Widgets](../perfumes_salazar/lib/custom_code/widgets/) |
| Cinco funciones personalizadas | Buscar por nombre, marca o aroma, agregar unidades, revisar subtotales y aplicar un cupón. Esos pasos usan `coincidePerfume`, `cantidadDisponible`, `formatoColones`, `calcularSubtotal` y `calcularDescuento`. [Funciones del catálogo](../perfumes_salazar/lib/custom_code/functions/catalogo.dart) |
| Fidelidad visual | Comparar bienvenida, catálogo, detalle, favoritos y pedidos con la navegación y la identidad visual del prototipo. [Prototipo del Avance 2](prototipo/) |
| Aplicación de prácticas e investigación | Seguir una operación desde el acceso hasta la escritura privada en Firestore. Las funciones HTTPS reservan el inventario en una transacción y reconocen los reintentos. [Funciones de pedidos](../firebase/functions/index.js) |
| Aplicabilidad comercial | El artículo compara el catálogo, los filtros y la atención de tres comercios costarricenses. [Análisis de mercado](articulo-perfumes-salazar.md) |
| Presentación del artículo | El recorrido relaciona problema, método, comparación de mercado, desarrollo y resultados con las operaciones de la app. [Guía de exposición](articulo-perfumes-salazar.md) |

## Datos de la demostración

| Colección raíz | Uso |
|---|---|
| `users` | Perfiles y rol que controla el acceso a administración |
| `products` | Fichas de fragancias, imágenes y visibilidad |
| `presentaciones` | Volumen, precio y existencias de cada variante |
| `categorias` | Clasificación de fragancias y filtros |
| `marcas` | Marcas del catálogo |
| `promociones` | Códigos de descuento con período de vigencia |
| `pedidos` | Solicitud con precios aceptados, descuento, total, propietario y estado |
| `movimientos_inventario` | Reserva o devolución vinculada al pedido y a sus presentaciones |

Las subcolecciones `users/{uid}/favoritos` y `users/{uid}/carrito` guardan las selecciones de cada cliente. El servidor calcula el total en colones, coteja las cantidades y guarda en la misma transacción el pedido, el movimiento y las existencias. La cancelación de un pedido pendiente restituye cada unidad una sola vez. [Prueba reproducible](../firebase/scripts/verificar.cjs)

## Contacto y pagos

El pedido registra una solicitud para seguimiento. WhatsApp abre una consulta con su identificador. Para dirigir el mensaje a la tienda, la compilación admite `WHATSAPP_COMERCIO` con el número internacional del comercio. La demostración permite seleccionar el destinatario al compartir. El cobro por SINPE Móvil o efectivo corresponde a la coordinación comercial posterior.
