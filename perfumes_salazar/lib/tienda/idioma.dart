import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final idiomaApp = ValueNotifier<Locale>(const Locale('es', 'CR'));
Future<void> cargarIdioma() async {
  final preferencias = await SharedPreferences.getInstance();
  if (preferencias.getString('idioma') == 'en')
    idiomaApp.value = const Locale('en');
}

Future<void> cambiarIdioma(String codigo) async {
  final preferencias = await SharedPreferences.getInstance();
  await preferencias.setString('idioma', codigo);
  idiomaApp.value =
      codigo == 'en' ? const Locale('en') : const Locale('es', 'CR');
}

const _ingles = <String, String>{
  "Inicio": "Home",
  "Catálogo": "Catalog",
  "Favoritos": "Favorites",
  "Carrito": "Cart",
  "Perfil": "Profile",
  "Administración": "Administration",
  "Confirmar pedido": "Confirm order",
  "Mis pedidos": "My orders",
  "Iniciar sesión": "Sign in",
  "Crear cuenta": "Create account",
  "Recuperar contraseña": "Reset password",
  "Colección de perfumes": "Perfume collection",
  "Buscar por nombre, marca o aroma": "Search by name, brand or scent",
  "Todos": "All",
  "Todas las marcas": "All brands",
  "En existencia": "In stock",
  "Menor precio": "Lowest price",
  "Mayor precio": "Highest price",
  "Nombre": "Name",
  "No se encontraron perfumes.": "No perfumes match your search.",
  "Explorar catálogo": "Explore catalog",
  "Aún no has guardado perfumes.": "You haven’t saved any perfumes yet.",
  "No hay perfumes disponibles en esta lista.":
      "No perfumes are available in this list.",
  "Guardar en favoritos": "Save to favorites",
  "Quitar de favoritos": "Remove from favorites",
  "Detalle del perfume": "Perfume details",
  "Este producto ya no está disponible.":
      "This product is no longer available.",
  "Sin presentaciones disponibles.": "No sizes available.",
  "Agregar al carrito": "Add to cart",
  "Agregado al carrito.": "Added to cart.",
  "Precio": "Price",
  "Cantidad": "Quantity",
  "Descuento": "Discount",
  "Total": "Total",
  "Subtotal": "Subtotal",
  "Código": "Code",
  "Productos": "Products",
  "Categorías": "Categories",
  "Marcas": "Brands",
  "Promociones": "Promotions",
  "Resumen": "Overview",
  "Pedidos": "Orders",
  "Productos activos": "Active products",
  "Productos agotados": "Out-of-stock products",
  "Pedidos pendientes": "Pending orders",
  "Total entregado": "Delivered order value",
  "Correo electrónico": "Email address",
  "Contraseña": "Password",
  "Confirmar contraseña": "Confirm password",
  "Revisa la contraseña.": "Check the password.",
  "Usa al menos 8 caracteres.": "Use at least 8 characters.",
  "Ingresa un correo válido.": "Enter a valid email address.",
  "Las contraseñas no coinciden.": "The passwords do not match.",
  "Enviar enlace": "Send link",
  "Continuar con Google": "Continue with Google",
  "Olvidé mi contraseña": "Forgot my password",
  "Explorar como invitado": "Browse as a guest",
  "Ese correo ya tiene una cuenta.": "This email already has an account.",
  "La contraseña es demasiado corta.": "The password is too short.",
  "Se cerró el acceso con Google.": "Google sign-in was closed.",
  "Revisa tu conexión a Internet.": "Check your internet connection.",
  "No se pudo iniciar la operación. Revisa los datos e inténtalo de nuevo.":
      "Could not complete the request. Check your details and try again.",
  "Si tienes una cuenta, recibirás un enlace para restablecer tu contraseña.":
      "If you have an account, you will receive a password reset link.",
  "No se pudo cargar el perfil. Comprueba la conexión y los permisos.":
      "Could not load your profile. Check your connection and permissions.",
  "Carrito vacío · Explorar catálogo": "Your cart is empty · Explore catalog",
  "Disminuir": "Decrease",
  "Aumentar": "Increase",
  "Quitar": "Remove",
  "Revisa los artículos agotados antes de confirmar.":
      "Review unavailable items before confirming.",
  "Código de promoción": "Promo code",
  "Aplicar código": "Apply code",
  "El código no está vigente.": "This code is not valid.",
  "Solicitud enviada.": "Order request sent.",
  "Enviando…": "Sending…",
  "Enviar solicitud de pedido": "Submit order request",
  "Revisar pedido": "Review order",
  "Todavía no hay pedidos.": "No orders yet.",
  "Cancelar pedido": "Cancel order",
  "Compartir consulta por WhatsApp": "Share inquiry on WhatsApp",
  "Contactar a la tienda por WhatsApp": "Contact the store on WhatsApp",
  "¿Cancelar este pedido y devolver las unidades al inventario?":
      "Cancel this order and return its items to stock?",
  "Volver": "Back",
  "Confirmar": "Confirm",
  "Editar información personal": "Edit personal information",
  "Mi perfil": "My profile",
  "Teléfono": "Phone number",
  "Panel de administración": "Admin dashboard",
  "Cerrar sesión": "Sign out",
  "Idioma de la aplicación": "App language",
  "No se pudieron consultar los datos. Comprueba tu conexión y los permisos.":
      "Could not load the data. Check your connection and access permissions.",
  "No se pudo completar la operación. Revisa tu conexión y vuelve a intentarlo.":
      "Could not complete the request. Check your connection and try again.",
  "Cancelar": "Cancel",
  "Guardar": "Save",
  "Cerrar": "Close",
  "Acceso reservado al personal administrador.":
      "Administrator access required.",
  "Visible": "Visible",
  "Oculto": "Hidden",
  "Gestionar presentaciones": "Manage sizes",
  "Agregar presentación": "Add size",
  "Presentación": "Size",
  "Familia olfativa": "Fragrance family",
  "Descripción": "Description",
  "Notas": "Notes",
  "URL de la imagen": "Image URL",
  "Marca": "Brand",
  "Categoría": "Category",
  "Porcentaje": "Percentage",
  "Desde (AAAA-MM-DD)": "Start date (YYYY-MM-DD)",
  "Hasta (fecha exclusiva)": "End date (exclusive)",
  "Volumen (ml)": "Volume (ml)",
  "Precio en colones": "Price in colones",
  "Completa este campo.": "Complete this field.",
  "Ingresa un entero válido.": "Enter a valid whole number.",
  "Usa una dirección HTTPS.": "Use an HTTPS address.",
  "Usa el formato AAAA-MM-DD.": "Use the YYYY-MM-DD format.",
  "Pendiente": "Pending",
  "Confirmado": "Confirmed",
  "En preparación": "Preparing",
  "Entregado": "Delivered",
  "Cancelado": "Cancelled",
  "Agotado": "Out of stock",
  "Disponibles": "Available",
  "Sin notas registradas": "No notes listed",
  "Estado sin registrar": "Unknown status",
  "Hombre": "Men",
  "Mujer": "Women",
  "Unisex": "Unisex",
  "LA ESENCIA DE LA ELEGANCIA": "THE ESSENCE OF ELEGANCE",
  "Descubre fragancias exclusivas diseñadas para cautivar tus sentidos.":
      "Discover exclusive fragrances designed to captivate your senses.",
  "INICIAR SESIÓN": "SIGN IN",
  "CREAR CUENTA": "CREATE ACCOUNT",
  "EXPLORAR COMO INVITADO": "BROWSE AS A GUEST",
  "O": "OR",
};
String traducir(BuildContext contexto, String texto) {
  if (Localizations.localeOf(contexto).languageCode != 'en') return texto;
  final valor = _ingles[texto];
  if (valor != null) return valor;
  if (texto.startsWith('Iniciar sesión para acceder a '))
    return 'Sign in to continue';
  if (texto.startsWith('Pedido '))
    return texto.replaceFirst('Pedido ', 'Order ');
  if (texto.startsWith('Agregar · '))
    return 'Add · ${_ingles[texto.substring(10)] ?? texto.substring(10)}';
  if (texto.startsWith('Marcar como '))
    return 'Mark as ${{
          'confirmado': 'confirmed',
          'en preparacion': 'preparing',
          'entregado': 'delivered'
        }[texto.substring(12)] ?? texto.substring(12)}';
  if (texto.endsWith(' % de descuento'))
    return texto.replaceFirst(' % de descuento', '% off');
  return texto
      .replaceAll('Precio: ', 'Price: ')
      .replaceAll('Cantidad: ', 'Quantity: ')
      .replaceAll('Descuento: ', 'Discount: ')
      .replaceAll('Código: ', 'Code: ')
      .replaceAll('Disponibles: ', 'Available: ');
}

class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, this.style});
  final String texto;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) =>
      Text(traducir(context, texto), style: style);
}
