import 'package:flutter/material.dart';

class IndicadorStock extends StatefulWidget {
  const IndicadorStock({super.key, this.width, this.height, required this.stock});

  final double? width;
  final double? height;
  final int stock;

  @override
  State<IndicadorStock> createState() => _IndicadorStockState();
}

class _IndicadorStockState extends State<IndicadorStock> {
  @override
  Widget build(BuildContext context) {
    final disponible = widget.stock > 0;
    final colores = Theme.of(context).colorScheme;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: Chip(
          avatar: Icon(disponible ? Icons.check_circle_outline : Icons.block),
          label: Text(disponible ? 'Disponibles: ${widget.stock}' : 'Agotado'),
          backgroundColor:
              disponible ? colores.secondaryContainer : colores.errorContainer,
        ),
      ),
    );
  }
}
