# Perfumes Salazar

Aplicación web del curso **SC-703 Programación para Dispositivos Móviles**, Universidad Fidélitas, grupo G04. El catálogo permite buscar fragancias, comparar precios en colones y consultar existencias. Los clientes guardan favoritos, aplican promociones y envían solicitudes de pedido. El personal administra el inventario y da seguimiento a cada solicitud.

## Ejecutar la entrega en Windows

1. Instalar **Node.js 22 con npm** y **JDK 21**. Los comandos `node`, `npm` y `java` deben estar disponibles en la terminal.
2. Extraer el ZIP de demostración completo y abrir **`INICIAR-DEMO.cmd`**. La primera ejecución necesita acceso a Internet para descargar dependencias y emuladores.
3. Mantener abierta la ventana del lanzador y entrar a la aplicación local. [Abrir Perfumes Salazar](http://127.0.0.1:8765/)
4. Explorar como invitado o elegir una cuenta de prueba. La guía incluye las credenciales locales y el recorrido de compra. [Demostración con Firebase](firebase/DEMOSTRACION.md)

La carpeta `demo-web` del ZIP contiene la aplicación compilada. Para ejecutarla desde el código fuente, seguir las instrucciones de compilación de la misma guía.

## Recorrido para la defensa

- **Cliente.** Buscar Chanel, abrir la presentación de 100 ml, guardar el perfume en favoritos, ajustar la cantidad y aplicar `BIENVENIDA10`. El pedido muestra el precio aceptado y el descuento.
- **Inventario.** Al confirmar la solicitud, el sistema reserva las unidades. Cancelar un pedido pendiente devuelve las existencias y deja constancia del movimiento.
- **Administración.** Abrir el panel desde el perfil de administración. Cambiar la disponibilidad de una presentación o el estado de un pedido. La cuenta de cliente tiene acceso a sus operaciones personales.
- **Artículo.** Recorrer el problema comercial, el análisis de tres perfumerías, la arquitectura y los resultados del proyecto. [Artículo y guía de exposición](docs/articulo-perfumes-salazar.md)

En la comprobación local desde el navegador se completó la compra con BIENVENIDA10. FlutterFlow Test Mode compiló el proyecto y mostró el catálogo con fotografías y existencias. [Catálogo en Studio](docs/evidencias/FlutterFlow.jpg) · [Cupón](docs/evidencias/Cupon.jpg) · [Pedido](docs/evidencias/Pedido.jpg)

## Proyecto y documentación

| Recurso | Contenido |
|---|---|
| [Proyecto en FlutterFlow](https://app.flutterflow.io/project/perfumes-salazar-i0yn4x) | Editor del proyecto compartido |
| [Aplicación Flutter](perfumes_salazar/) | Código exportado y aplicación web |
| [Código personalizado de Studio](flutterflow-studio/main.dart) | Implementación preparada para el editor |
| [Servicios Firebase](firebase/) | Reglas de Firestore, funciones transaccionales, emuladores y pruebas |
| [Guía de la entrega final](docs/entrega-final-integracion.md) | Estado por entorno y evidencias según la rúbrica |
| [Historias de usuario](docs/historias-de-usuario.md) | Alcance de las 29 historias del Avance 2 |
| [Prototipo](docs/prototipo/) | Diseños en Figma y PDF |

## Equipo

| Integrante | Rol |
|------------|-----|
| Johan Sánchez Vásquez | Integrante del equipo |
| Alex Daniel Salazar Brenes | Integrante del equipo |
| Fabián Alberto Mora Cordero | Integrante del equipo |
| Patrick Garita Chinchilla | Integrante del equipo |
| Axel Segura Abarca | Integrante del equipo |
