# Integración de la entrega final en FlutterFlow

El código de esta carpeta de trabajo está preparado para integrar. Los archivos locales no registran widgets en el editor ni publican funciones o reglas de Firebase.

| Rubro | Código preparado | Verificación en el entorno |
|---|---|---|
| Ocho colecciones | users, products, presentaciones, categorias, marcas, promociones y pedidos, más las subcolecciones favoritos y carrito | Crear los esquemas, cargar datos de demostración y demostrar lecturas y escrituras por flujo |
| Transacciones | crearPedido y cancelarPedido en firebase/functions | Ejecutar ambos flujos y comprobar el movimiento de stock, la propiedad del pedido y el reintento |
| Autenticación y roles | Acceso por correo y Google configurados en Firebase. Reglas propuestas para roles cliente y admin | Probar cada proveedor y comprobar que el cliente tampoco puede escribir directamente en las colecciones administrativas |
| Tres widgets | IndicadorStock, NotasOlfativas, EstadoPedido | Registrarlos en Custom Code y enlazarlos en detalle y pedidos |
| Cinco funciones | formatoColones, coincidePerfume, cantidadDisponible, calcularSubtotal y calcularDescuento | Registrarlas por separado y enlazarlas en catálogo y carrito |
| Fidelidad y prácticas | Prototipo y 29 historias documentadas | Comparar las pantallas funcionales con el prototipo y cruzar los flujos con los laboratorios del curso |
| Tecnología adicional | Transacciones con funciones HTTPS invocables de Firebase | Confirmar contra el temario que esta tecnología es adicional y demostrar su uso |
| Aplicabilidad comercial | Proyecto de tienda de perfumes y catálogo de demostración | Sustentar con evidencia del cliente o análisis de mercado documentado |
| Caminata del artículo | Pendiente de incorporar el artículo de entrega | Exponer problema, método, arquitectura, resultados observados y limitaciones, señalando cada sección del artículo |

## Contrato de pedidos

La acción cliente llama a crearPedido con solicitudId, items (pares presentacionId y cantidad) y, opcionalmente, codigo. Conservar solicitudId durante un reintento. El servidor toma precio y stock de presentaciones, comprueba que cada producto siga activo, calcula el descuento y devuelve pedidoId y total. Cancelar con cancelarPedido y pedidoId. Los importes de presentaciones se almacenan como colones enteros.

Las reglas proponen lectura pública de catálogo activo y reservan la edición al rol admin. Los usuarios nuevos quedan limitados a cliente. Las consultas públicas deben filtrar activo o activa según la colección. La creación de pedidos se reserva a la función de servidor. Verificar las reglas en un entorno de prueba antes de publicarlas. Las promociones se validan en el servidor. Un listado público de promociones requiere una proyección separada con únicamente datos publicables.
