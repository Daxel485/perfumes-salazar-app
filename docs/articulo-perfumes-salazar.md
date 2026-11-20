# Diseño de una aplicación de catálogo y gestión de pedidos para Perfumes Salazar

**Borrador para revisión del equipo.** El texto distingue lo observado en el mercado, las decisiones de diseño y lo que debe comprobarse en el prototipo.

## Resumen

Perfumes Salazar propone centralizar la consulta de fragancias, su disponibilidad y las solicitudes de pedido. Se revisaron tres ofertas costarricenses y se planteó un flujo que combina exploración pública, carrito, solicitud autenticada y seguimiento. La arquitectura usa FlutterFlow para la interfaz y Firebase para sesiones y datos. Los resultados de ejecución integral y la evaluación con usuarios quedan pendientes.

## Introducción

Una compra de perfumería puede empezar en un catálogo y pasar a un chat para confirmar precio, disponibilidad y entrega. El objetivo es mantener el contexto de la compra desde la búsqueda hasta la solicitud, con un registro que el cliente y la administración puedan consultar.

## Método

Se hizo una revisión documental de tres tiendas costarricenses. Se registraron las funciones visibles en sus páginas y se contrastaron con el prototipo y las historias del Avance 2. La muestra fue intencional y pequeña. El análisis no estima tamaño de mercado, ventas, conversión ni satisfacción.

| Oferta observada | Función visible | Decisión que informa |
|---|---|---|
| [Pura Esencia](https://www.puraesenciacr.com/) | Catálogo y asistencia por WhatsApp para consultar disponibilidad y precio | Mantener una vía de contacto y presentar existencias en la ficha |
| [Casa Aroma](https://www.casaaromacr.com/tienda/) | Catálogo con clasificación por tipo y filtro de precio | Incorporar filtros y ordenar el catálogo |
| [Soluna Perfumería](https://solunafragrance.com/) | La finalización del carrito abre un mensaje de WhatsApp con el pedido | Guardar la solicitud antes del contacto para poder mostrar su historial |

Fuentes consultadas el 19 de noviembre de 2026. La última columna describe decisiones del proyecto a partir de lo observado y no afirma exclusividad comercial.

## Diseño e implementación

El prototipo guía la navegación, la paleta y la jerarquía de las pantallas. El visitante puede consultar el catálogo y autenticarse al iniciar una operación privada. El diseño separa el perfil de cliente de la administración de productos, pedidos y promociones. La interfaz y las reglas de Firebase deben aplicar esa separación.

El módulo de pedidos preparado comprueba precios y existencias en el servidor. La creación registra los importes y descuenta existencias en una sola transacción. La cancelación de una solicitud pendiente devuelve las unidades. El identificador de solicitud permite reconocer un reintento sin crear otro pedido.

## Resultados y limitaciones

En Firebase se comprobó la habilitación de correo y contraseña y del proveedor Google. El editor tiene un catálogo conectado a productos de demostración y una referencia que apunta a la ficha correspondiente. El código local incluye funciones de catálogo y carrito, widgets y operaciones transaccionales. Aún falta comprobar la ejecución de esos módulos dentro de FlutterFlow y ejecutar los casos de cliente y administrador. No se dispone de métricas de uso ni resultados de validación directa con el negocio.

## Conclusiones

El análisis muestra que catálogo, filtros y atención por mensajería son funciones pertinentes para este mercado. El aporte planteado es conservar el registro de cada solicitud y relacionarlo con inventario y estados. La evaluación final debe demostrar que el flujo de compra y cancelación mantiene esos datos consistentes.

## Recorrido del artículo para la defensa

1. Abrir la introducción y mostrar cómo una solicitud registrada responde al problema del cambio entre catálogo y chat.
2. Mostrar la tabla del método. Separar lo que se observó en las tiendas de las decisiones propias de Perfumes Salazar.
3. Abrir diseño e implementación. Relacionar el prototipo con catálogo, detalle, roles y pedidos.
4. Ir a resultados y mostrar únicamente las comprobaciones realizadas. Incorporar antes de la defensa las evidencias de ejecución que falten.
5. Cerrar con las conclusiones y explicar qué validación queda pendiente con clientes reales.
