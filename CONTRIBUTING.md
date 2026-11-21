# Cómo trabajamos

La rúbrica cuenta **pull requests con código significativo de cada integrante**. El equipo tiene cinco integrantes: para el Avance 3 se necesita al menos un aporte significativo de cada uno; la defensa final pide tres por persona, separados por al menos una semana. Nadie hace push directo a `main`. Un PR de documentación o generado por otra persona no acredita código propio del integrante.

## Primera vez

```bash
git clone https://github.com/Daxel485/perfumes-salazar-app.git
cd perfumes-salazar-app
```

## Cada tarea

```bash
git checkout main
git pull
git checkout -b feature/hu-09-filtros
# ... cambios ...
git add .
git commit -m "feat(catalogo): filtros por categoría (HU-09)"
git push -u origin feature/hu-09-filtros
```

Luego, en GitHub: **Compare & pull request** → base `main` → usar la plantilla → pedir revisión a otro integrante. Quien revisa aprueba y hace **Merge**. Después todos hacen `git pull` en `main`.

## Nombres de ramas

- `feature/hu-XX-descripcion` — funcionalidad de una historia
- `fix/descripcion` — corrección
- `docs/descripcion` — documentación
- `chore/snapshot-flutterflow` — actualizar `app/` con el código generado

## Custom code (FlutterFlow ↔ repo)

1. Escribir el widget/action/function en `custom_code/widgets|actions|functions/` con el mismo nombre que tendrá en FlutterFlow.
2. Abrir el PR, que lo revisen y mergearlo.
3. Copiar el código a FlutterFlow → *Custom Code* → **Compile**, y usarlo en la pantalla.

## Mensajes de commit

`tipo(área): qué se hizo (HU-XX)` — tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`.
