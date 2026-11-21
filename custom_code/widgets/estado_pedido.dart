import 'package:flutter/material.dart';

class EstadoPedido extends StatefulWidget {
  const EstadoPedido({super.key, this.width, this.height, required this.estado});

  final double? width;
  final double? height;
  final String estado;

  @override
  State<EstadoPedido> createState() => _EstadoPedidoState();
}

class _EstadoPedidoState extends State<EstadoPedido> {
  @override
  Widget build(BuildContext context) {
    final (etiqueta, icono) = switch (widget.estado) {
      'pendiente' => ('Pendiente', Icons.schedule),
      'confirmado' => ('Confirmado', Icons.check_circle_outline),
      'en_preparacion' => ('En preparación', Icons.inventory_2_outlined),
      'entregado' => ('Entregado', Icons.done_all),
      'cancelado' => ('Cancelado', Icons.cancel_outlined),
      _ => ('Estado sin registrar', Icons.info_outline),
    };
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(child: Chip(avatar: Icon(icono), label: Text(etiqueta))),
    );
  }
}
