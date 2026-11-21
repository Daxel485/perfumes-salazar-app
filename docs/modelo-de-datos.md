# Modelo de datos de Perfumes Salazar

Este documento distingue el esquema **creado en FlutterFlow** del modelo previsto para las demás historias. Crear un esquema no equivale a cargar documentos, configurar reglas ni conectar las pantallas.

## Esquema creado

| Colección | Campos | Historias relacionadas |
|---|---|---|
| `users` | `email`, `display_name`, `photo_url`, `uid`, `created_time`, `phone_number`, `role` (`cliente` o `admin`) | HU-01, HU-02, HU-04 |
| `products` | `nombre`, `marca`, `categoria`, `descripcion`, `notas`, `aroma`, `imagen`, `precio`, `stock`, `activo` | HU-06 a HU-09 |

`precio` es `Double` y representa colones costarricenses; `stock` es `Integer`. `activo` controla la visibilidad. La interfaz debe impedir agregar al carrito cuando `stock` es cero. Los nombres de colecciones son los identificadores reales de FlutterFlow y Firestore; no se deben traducir unilateralmente.

## Datos comprobados en Firebase

La consola de Firestore muestra cuatro colecciones raíz con documentos. `products` contiene los tres perfumes. `marcas` contiene Dior, Chanel e Yves Saint Laurent. `categorias` contiene Hombre y Mujer. Cada documento de marca y categoría incluye el nombre y el booleano `activa`.

La colección raíz `presentaciones` vincula cada variante con el ID real de su documento en `products` mediante `producto_id`. Se cargaron presentaciones de demostración de 100 ml.

| Documento | Precio en colones | Existencias iniciales |
|---|---:|---:|
| sauvage-100 | 68 500 | 7 |
| black-opium-100 | 73 500 | 0 |
| chanel-5-100 | 79 500 | 4 |

## Modelo de los flujos de cliente

| Colección | Campos propuestos | Historias relacionadas |
|---|---|---|
| `presentaciones` | `producto_id`, `ml`, `precio`, `stock`, `activa` | HU-07, HU-13 |
| `users/{uid}/favoritos` | `producto_ref`, `created_time` | HU-12 |
| `users/{uid}/carrito` | `producto_ref`, `presentacion_ref`, `precio_unitario`, `cantidad` | HU-13, HU-14 |
| `categorias` | `nombre`, `orden`, `activa` | HU-09, HU-27 |
| `marcas` | `nombre`, `logo`, `activa` | HU-09, HU-27 |
| `pedidos` | `user_ref`, `items`, `subtotal`, `total`, `estado`, `created_time` | HU-16 a HU-18, HU-28 |
| `promociones` | `codigo`, `porcentaje`, `inicio`, `fin`, `activa` | HU-11, HU-15, HU-29 |

La defensa final requiere al menos ocho colecciones, incluida una transaccional (`pedidos`). Esa meta no implica que las colecciones pendientes existan en este avance.

## Seguridad prevista

- Lectura pública de productos activos, categorías y marcas.
- Escritura de catálogo reservada a administradores verificados por `users/{uid}.role`.
- Favoritos y carrito accesibles solo por su propietario.
- Los pedidos se leen por su cliente; el cambio de estado se reserva a administradores.

Las reglas deben desplegarse y probarse antes de usar datos reales. Firebase Authentication tiene habilitados correo y contraseña y el proveedor Google. La prueba de acceso con cada perfil sigue pendiente.
