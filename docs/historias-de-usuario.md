# Historias de usuario oficiales — Avance 2

La fuente de esta numeración es `G04_SC703_KN_Avance2.docx`, tabla «Historias de usuario». El documento contiene **29 historias**. La rúbrica del Avance 3 exige que al menos el 40 % esté implementado **y funcione** conforme al prototipo: `ceil(29 × 0,40) = 12` historias. Una pantalla o dato de muestra sin acción comprobada no cuenta como implementación funcional.

| ID | Historia oficial | Pantalla principal del prototipo | Meta Avance 3 |
|---|---|---|:---:|
| HU-01 | Registro de cliente | 03 Registro | ✓ |
| HU-02 | Inicio de sesión | 02 Iniciar sesión | ✓ |
| HU-03 | Recuperar contraseña | 02 Iniciar sesión | ✓ |
| HU-04 | Cerrar sesión | 13 Perfil | ✓ |
| HU-05 | Gestionar perfil | 13 Perfil | |
| HU-06 | Ver catálogo de perfumes | 04 Inicio, 05 Catálogo | ✓ |
| HU-07 | Ver detalle del perfume | 06 Detalle | ✓ |
| HU-08 | Buscar perfumes | 04 Inicio, 05 Catálogo | ✓ |
| HU-09 | Filtrar y ordenar productos | 05 Catálogo | ✓ |
| HU-10 | Explorar como invitado | 01 Bienvenida, 05 Catálogo | ✓ |
| HU-11 | Ver promociones en el inicio | 04 Inicio | |
| HU-12 | Gestionar favoritos | 05 Catálogo, 06 Detalle, 07 Favoritos | ✓ |
| HU-13 | Agregar al carrito | 06 Detalle, 08 Carrito | ✓ |
| HU-14 | Modificar el carrito | 08 Carrito | ✓ |
| HU-15 | Aplicar código de promoción | 08 Carrito | |
| HU-16 | Enviar solicitud de pedido | 09 Confirmar, 10 Solicitud enviada | |
| HU-17 | Consultar mis pedidos | 11 Mis pedidos, 12 Detalle pedido | |
| HU-18 | Cancelar solicitud pendiente | 12 Detalle pedido | |
| HU-19 | Contactar por WhatsApp | 12 Detalle pedido | |
| HU-20 | Cambiar idioma | 13 Perfil | |
| HU-21 | Acceso por rol de administrador | 13 Perfil, 14 Panel | |
| HU-22 | Panel con indicadores | 14 Panel | |
| HU-23 | Registrar producto | 16 Agregar producto | |
| HU-24 | Editar y eliminar producto | 15 Productos, 16 Editar producto | |
| HU-25 | Gestionar imágenes del producto | 16 Agregar/editar producto | |
| HU-26 | Gestionar disponibilidad y visibilidad | 15 Productos, 16 Editar producto | |
| HU-27 | Gestionar categorías y marcas | 17 Categorías y marcas | |
| HU-28 | Gestionar estado de pedidos | 18 Pedidos, 19 Gestionar pedido | |
| HU-29 | Gestionar promociones | 20 Promociones | |

## Condición para marcar una historia como terminada

Debe cumplir **todos** los criterios de aceptación del Avance 2, ejecutarse en Test Mode con datos persistentes cuando corresponda y conservar los componentes y la navegación de la pantalla del prototipo. Los registros de prueba y las capturas se documentan en `docs/avance-3-evidencias.md`.
