# Guía de diseño (tomada del prototipo)

Pantallas de 390 × 844 (iPhone 14). Estilo cálido, elegante, fondo crema con acentos dorados.

## Colores → FlutterFlow *Theme Settings*

| Rol FlutterFlow | Hex | Uso en el prototipo |
|-----------------|-----|---------------------|
| Primary | `#1A1613` | Botones principales, chip seleccionado, banner de promo, títulos |
| Secondary | `#B8893B` | Dorado: marca del perfume, "Ver todo", botón "Ver promoción", ítem activo de la barra inferior |
| Tertiary | `#3D7C59` | Verde: "Disponible", estados positivos |
| Primary Background | `#F6F2ED` | Fondo de pantallas |
| Secondary Background | `#FFFFFF` | Tarjetas, campos de texto, chips no seleccionados |
| Primary Text | `#1A1613` | Texto principal |
| Secondary Text | `#797069` | Subtítulos, placeholders |
| Alternate | `#E6DDD4` | Bordes y divisores |
| Error | `#B3463A` | Corazón de favorito, "Agotado", errores |
| Success | `#3D7C59` | |
| Warning | `#B8893B` | "Pocas unidades" |
| Info | `#3D5977` | |

Fondos de las tarjetas de producto (pastel, uno por perfume): `#E6EDF2`, `#F2E4E4`, `#E2EFE8`, `#F2E8DB`, `#F4E8EB`.

## Tipografía

- **Títulos** (Display / Headline / Title): *Playfair Display* — "Perfumes Salazar", "Hola, María", "Categorías", nombre del perfume en el detalle.
- **Cuerpo y botones** (Label / Body): *Inter*.
- Marca del perfume: Inter 11–12, mayúsculas, espaciado, color Secondary.

## Componentes recurrentes

- **Tarjeta de producto**: imagen sobre fondo pastel, radio 16, marca (dorado, mayúsculas), nombre, precio `₡68 000`, corazón arriba a la derecha y botón negro "+" redondeado.
- **Chips de categoría**: píldoras, seleccionado negro con texto blanco, resto blanco con borde `#E6DDD4`.
- **Botón primario**: alto 52, radio 14, fondo `#1A1613`, texto blanco.
- **Barra inferior cliente**: Inicio · Catálogo · Favoritos · Carrito · Perfil.
- **Barra inferior admin**: Panel · Productos · Pedidos · Promociones · Más.
- **Precios**: colones con espacio de miles (`₡166 920`).
