# Modelo de datos (Firestore + Storage)

La defensa final exige **≥ 8 colecciones** en Firestore y **al menos una de transacciones**. Aquí hay 11; `pedidos` es la colección transaccional.

## Colecciones

| # | Colección | Tipo | Campos principales | HU |
|---|-----------|------|--------------------|----|
| 1 | `users` | raíz | `display_name`, `email`, `phone_number`, `photo_url`, `role` (`cliente` \| `admin`), `idioma`, `notif_promos` (bool), `created_time` | 02–05, 13, 19 |
| 2 | `categorias` | raíz | `nombre`, `orden` (int), `activa` (bool) | 06, 07, 16 |
| 3 | `marcas` | raíz | `nombre`, `logo` (imagen) | 07, 15, 16 |
| 4 | `productos` | raíz | `nombre`, `marca_ref`, `marca_nombre`, `categoria_ref`, `tipo` (EDP/EDT/Parfum), `descripcion`, `nota_salida`, `nota_corazon`, `nota_fondo`, `imagenes` (lista), `color_fondo`, `precio_desde` (int ₡), `stock_total` (int), `visible`, `destacado`, `created_time` | 06–08, 15 |
| 5 | `productos/{id}/presentaciones` | subcolección | `ml` (int), `precio` (int ₡), `stock` (int) | 08, 10, 15 |
| 6 | `users/{uid}/favoritos` | subcolección | `producto_ref`, `created_time` | 09 |
| 7 | `users/{uid}/carrito` | subcolección | `producto_ref`, `nombre`, `marca`, `imagen`, `ml`, `precio_unitario`, `cantidad` | 10, 11 |
| 8 | `users/{uid}/direcciones` | subcolección | `alias`, `provincia`, `canton`, `detalle`, `predeterminada` | 11, 13 |
| 9 | `pedidos` ⭐ transacción | raíz | `numero` (`PS-1048`), `user_ref`, `cliente_nombre`, `cliente_telefono`, `items` (lista de *ItemPedido*), `subtotal`, `descuento`, `codigo_promo`, `envio`, `total`, `entrega` (`domicilio` \| `retiro`), `direccion`, `metodo_pago` (`sinpe` \| `efectivo`), `notas`, `estado` (`pendiente` \| `confirmado` \| `en_camino` \| `entregado` \| `cancelado`), `created_time` | 11, 12, 14, 17 |
| 10 | `pedidos/{id}/historial` | subcolección | `estado`, `nota`, `fecha`, `admin_ref` | 12, 17 |
| 11 | `promociones` | raíz | `codigo`, `descripcion`, `porcentaje`, `inicio`, `fin`, `todo_catalogo` (bool), `productos_refs` (lista), `banner` (imagen), `activa` | 06, 10, 18 |

Data type (struct) **`ItemPedido`**: `producto_ref`, `nombre`, `ml`, `precio_unitario`, `cantidad`.

Contador de número de pedido: documento `config/contadores` con `ultimo_pedido` (int), actualizado en la misma acción que crea el pedido.

## Firebase Storage

```
productos/{productoId}/{n}.jpg     imágenes del perfume (HU-15)
marcas/{marcaId}.png               logos (HU-16)
promociones/{promoId}.jpg          banners (HU-18)
users/{uid}/avatar.jpg             foto de perfil (HU-13)
```

## Reglas (resumen)

- `productos`, `categorias`, `marcas`, `promociones`: lectura pública; escritura solo si `users/{uid}.role == 'admin'`.
- `users/{uid}` y sus subcolecciones: solo el propio usuario (y admin lectura).
- `pedidos`: el cliente crea y lee los suyos; solo admin cambia `estado`; el cliente puede pasar a `cancelado` solo si está `pendiente`.

## Autenticación (≥ 2 tipos)

1. Correo y contraseña (HU-02, HU-03, HU-05)
2. Google (HU-04)
