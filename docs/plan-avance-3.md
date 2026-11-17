# Plan — Avance 3 (semana 10, 10 %)

## Qué evalúa la rúbrica

| Rubro | Excelente (3,33) |
|-------|------------------|
| Implementación de las historias de usuario | ≥ 40 % de las HU implementadas |
| Funcionalidad | ≥ 40 % de las HU y **fiel al prototipo** del Avance 2 |
| Participación en GitHub | **100 % de los miembros** con PR/pull significativo de código |

Para la defensa final además cuentan: 3 PR por persona **separados al menos 1 semana**, ≥ 8 colecciones con una transaccional, 2 tipos de autenticación con roles que limitan opciones, 3 custom widgets, Firebase Storage medular y una tecnología no vista en clase. Conviene que el Avance 3 ya deje encaminado todo eso.

## Reparto

Cada integrante hace **su propia rama y su propio PR** con código Dart real (custom widget, custom action o custom function) además de armar sus pantallas en FlutterFlow.

| Integrante | HU | Pantallas FlutterFlow | Código para su PR (`custom_code/`) |
|------------|----|-----------------------|------------------------------------|
| Axel Segura | HU-01 a HU-05, HU-19 | Bienvenida, Iniciar sesión, Crear cuenta, Recuperar contraseña; colección `users` con `role`; Firebase + Auth | `functions/es_admin.dart`, `functions/formatear_colones.dart` |
| Integrante 2 | HU-06, HU-07 | Inicio, Catálogo (filtro por categoría, búsqueda, orden) | **Custom widget** `ChipsCategorias` (chips horizontales seleccionables) |
| Integrante 3 | HU-08, HU-09 | Detalle de perfume, Favoritos | **Custom widget** `SelectorPresentacion` (60/100/200 ml) |
| Integrante 4 | HU-10, HU-11 | Carrito, Confirmar pedido, Solicitud enviada | **Custom widget** `StepperCantidad` + action `crearPedido` (número `PS-xxxx`) |

> Cambien "Integrante 2/3/4" por los nombres reales.

## Orden de trabajo

1. **Axel** — dejar listo: proyecto FlutterFlow, Firebase conectado (Auth correo + Google, Firestore, Storage), tema (colores/fuentes del prototipo), colecciones del `docs/modelo-de-datos.md`, datos semilla (categorías, marcas, 6–8 productos con imágenes en Storage) y navegación base (barra inferior Inicio · Catálogo · Favoritos · Carrito · Perfil).
2. Todos — se agregan como colaboradores **Editor** en FlutterFlow y como colaboradores del repo.
3. Cada uno trabaja sus pantallas en FlutterFlow **en su propio branch de FlutterFlow** (Branching) o coordinando quién edita qué página, para no pisarse.
4. Cada uno escribe su código en el repo (`custom_code/...`) en una rama `feature/...`, abre PR a `main`, otro integrante lo revisa y aprueba, y luego se pega/sincroniza en FlutterFlow → *Custom Code*.
5. Al cerrar, se sube el snapshot del código generado (`app/`) con un PR `chore: snapshot FlutterFlow avance 3`.
6. Entrega: link del repo + link del proyecto FlutterFlow (profe como Editor) + capturas/APK web.

## Checklist de entrega

- [ ] 12 HU funcionando en Test Mode / Run Mode
- [ ] Pantallas fieles al prototipo (colores, tipografía, orden de elementos)
- [ ] 4 PR mergeados, uno por integrante, con código significativo
- [ ] Roles: opción “Panel de administración” solo visible si `role == admin`
- [ ] Profe agregado como Editor en FlutterFlow
- [ ] README actualizado con capturas
