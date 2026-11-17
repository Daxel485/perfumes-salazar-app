# Modelo de datos (Firestore + Storage)

La defensa final exige **≥ 8 colecciones** en Firestore y **al menos una de transacciones**. Hay **12 colecciones raíz** ya creadas en FlutterFlow; `pedidos` es la colección transaccional.

> La API de FlutterFlow no maneja subcolecciones, así que las relaciones se hacen con campos de referencia (`user_ref`, `producto_ref`, `pedido_ref`).

## Colecciones

| # | Colección | Tipo | Campos principales | HU |
|---|-----------|------|--------------------|----|
| 1 | `users` | raíz | `display_name`, `email`, `phone_number`, `photo_url` (ImagePath), `uid`, `role` (`cliente` \| `admin`), `idioma`, `notif_promos` (bool), `created_time` | 02–05, 13, 19 |
| 2 | `categorias` | raíz | `nombre`, `orden` (int), `activa` (bool) | 06, 07, 16 |
| 3 | `marcas` | raíz | `nombre`, `logo` (imagen) | 07, 15, 16 |
| 4 | `productos` | raíz | `nombre`, `marca_ref`, `marca_nombre`, `categoria_ref`, `tipo` (EDP/EDT/Parfum), `descripcion`, `nota_salida`, `nota_corazon`, `nota_fondo`, `imagenes` (lista), `color_fondo`, `precio_desde` (int ₡), `stock_total` (int), `visible`, `destacado`, `created_time` | 06–08, 15 |
| 5 | `presentaciones` | raíz | `producto_ref`, `ml` (int), `precio` (int ₡), `stock` (int) | 08, 10, 15 |
| 6 | `favoritos` | raíz | `user_ref`, `producto_ref`, `created_time` | 09 |
| 7 | `carrito` | raíz | `user_ref`, `producto_ref`, `nombre`, `marca`, `imagen`, `ml`, `precio_unitario`, `cantidad` | 10, 11 |
| 8 | `direcciones` | raíz | `user_ref`, `alias`, `provincia`, `canton`, `detalle`, `predeterminada` | 11, 13 |
| 9 | `pedidos` ⭐ transacción | raíz | `numero` (`PS-1048`), `user_ref`, `cliente_nombre`, `cliente_telefono`, `items_nombres`, `items_cantidades`, `items_precios` (listas paralelas), `cantidad_productos`, `subtotal`, `descuento`, `codigo_promo`, `envio`, `total`, `entrega` (`domicilio` \| `retiro`), `direccion`, `metodo_pago` (`sinpe` \| `efectivo`), `notas`, `estado` (`pendiente` \| `confirmado` \| `en_camino` \| `entregado` \| `cancelado`), `created_time` | 11, 12, 14, 17 |
| 10 | `historial_pedidos` | raíz | `pedido_ref`, `estado`, `nota`, `fecha`, `admin_ref` | 12, 17 |
| 11 | `promociones` | raíz | `codigo`, `descripcion`, `porcentaje`, `inicio`, `fin`, `todo_catalogo` (bool), `productos_refs` (lista), `banner` (imagen), `activa` | 06, 10, 18 |
| 12 | `config` | raíz | `ultimo_pedido` (int): contador para el número `PS-xxxx` | 11 |

## Firebase Storage

> Pendiente: Storage exige el plan **Blaze** en proyectos nuevos de Firebase.

```
productos/{productoId}/{n}.jpg     imágenes del perfume (HU-15)
marcas/{marcaId}.png               logos (HU-16)
promociones/{promoId}.jpg          banners (HU-18)
users/{uid}/avatar.jpg             foto de perfil (HU-13)
```

## Reglas desplegadas hoy (desarrollo)

- Lectura y creación: todos. Escritura: usuarios autenticados (en `users`, solo el dueño). Borrado: autenticados en `favoritos`, `carrito` y `direcciones`; nadie en el resto.
- Antes de la defensa, endurecer según el objetivo de abajo.

## Reglas objetivo (resumen)

- `productos`, `categorias`, `marcas`, `promociones`: lectura pública; escritura solo si `users/{uid}.role == 'admin'`.
- `users/{uid}` y sus subcolecciones: solo el propio usuario (y admin lectura).
- `pedidos`: el cliente crea y lee los suyos; solo admin cambia `estado`; el cliente puede pasar a `cancelado` solo si está `pendiente`.

## Autenticación (≥ 2 tipos)

1. Correo y contraseña (HU-02, HU-03, HU-05)
2. Google (HU-04)
