import 'package:intl/intl.dart';

String formatoColones(int monto) {
  final formato = NumberFormat.decimalPattern('es_CR');
  return '₡${formato.format(monto)}';
}

bool coincidePerfume(String consulta, String nombre, String marca, String aroma) {
  String normalizar(String texto) {
    const origen = 'áéíóúü';
    const destino = 'aeiouu';
    var resultado = texto.toLowerCase();
    for (var i = 0; i < origen.length; i++) {
      resultado = resultado.replaceAll(origen[i], destino[i]);
    }
    return resultado.trim();
  }

  final palabras = normalizar(consulta).split(RegExp(r'\s+'));
  final texto = normalizar('$nombre $marca $aroma');
  return palabras.every(texto.contains);
}

bool cantidadDisponible(int cantidad, int stock) {
  return cantidad > 0 && cantidad <= stock;
}

int calcularSubtotal(int precioUnitario, int cantidad) {
  if (precioUnitario < 0 || cantidad < 1) return 0;
  return precioUnitario * cantidad;
}

int calcularDescuento(int subtotal, int porcentaje) {
  if (subtotal < 1 || porcentaje < 1 || porcentaje > 100) return 0;
  return (subtotal * porcentaje + 50) ~/ 100;
}
