import 'package:flutter/material.dart';

class NotasOlfativas extends StatefulWidget {
  const NotasOlfativas({super.key, this.width, this.height, required this.notas});

  final double? width;
  final double? height;
  final String notas;

  @override
  State<NotasOlfativas> createState() => _NotasOlfativasState();
}

class _NotasOlfativasState extends State<NotasOlfativas> {
  @override
  Widget build(BuildContext context) {
    final etiquetas = widget.notas
        .split(RegExp(r'[,;\n]'))
        .map((nota) => nota.trim())
        .where((nota) => nota.isNotEmpty)
        .toSet();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        child: etiquetas.isEmpty
            ? const Text('Sin notas registradas')
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final nota in etiquetas)
                    Chip(avatar: const Icon(Icons.spa_outlined), label: Text(nota)),
                ],
              ),
      ),
    );
  }
}
