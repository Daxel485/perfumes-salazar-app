# Cómo trabajamos

La rúbrica cuenta **pull requests con código significativo de cada integrante** (Avance 3: al menos 1 por persona; defensa final: 3 por persona, separados por al menos una semana). Nadie hace push directo a `main`.

## Primera vez

```bash
git clone https://github.com/Daxel485/perfumes-salazar-app.git
cd perfumes-salazar-app
```

## Cada tarea

```bash
git checkout main
git pull
git checkout -b feature/hu-07-catalogo
# ... cambios ...
git add .
git commit -m "feat(catalogo): chips de categorías como custom widget (HU-07)"
git push -u origin feature/hu-07-catalogo
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
