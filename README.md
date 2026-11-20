# Perfumes Salazar — App móvil

Proyecto del curso **SC-703 Programación para Dispositivos Móviles** (Universidad Fidélitas, grupo G04).

App para **Perfumes Salazar** (La Fortuna, San Carlos): los clientes exploran el catálogo de perfumes, guardan favoritos, arman su carrito y envían solicitudes de pedido que el negocio confirma por WhatsApp (pago SINPE Móvil o efectivo). El personal administra productos, categorías, marcas, pedidos y promociones desde la misma app.

## Stack

- **FlutterFlow** (Flutter / Dart) — UI y lógica
- **Firebase** — Authentication (correo + Google), Cloud Firestore, Storage
- **GitHub** — control de versiones y pull requests del equipo

**Proyecto FlutterFlow:** [Perfumes Salazar](https://app.flutterflow.io/project/perfumes-salazar-i0yn4x). El Avance 2 oficial define 29 historias de usuario; el mínimo de la rúbrica del Avance 3 es 12 historias funcionales. El estado comprobado se registra en [docs/avance-3-evidencias.md](docs/avance-3-evidencias.md).

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [docs/historias-de-usuario.md](docs/historias-de-usuario.md) | 29 historias oficiales y meta de 12 para el Avance 3 |
| [docs/modelo-de-datos.md](docs/modelo-de-datos.md) | Colecciones de Firestore, Storage, reglas y autenticación |
| [docs/plan-avance-3.md](docs/plan-avance-3.md) | Rúbrica, reparto por integrante y checklist |
| [docs/diseno.md](docs/diseno.md) | Colores, tipografías y componentes del prototipo |
| [docs/prototipo/](docs/prototipo/) | Prototipo Figma (PDF + `.fig`) del Avance 2 |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Cómo trabajar con ramas y pull requests |

## Estructura

```
app/            Snapshot del código Flutter generado por FlutterFlow (solo lectura)
custom_code/    Custom widgets, actions y functions escritos por el equipo (van por PR)
docs/           Historias, modelo de datos, plan y prototipo
```

## Equipo

| Integrante | Rol |
|------------|-----|
| Johan Sánchez Vásquez | Integrante del equipo |
| Alex Daniel Salazar Brenes | Integrante del equipo |
| Fabián Alberto Mora Cordero | Integrante del equipo |
| Patrick Garita Chinchilla | Integrante del equipo |
| Axel Segura Abarca | Integrante del equipo |
