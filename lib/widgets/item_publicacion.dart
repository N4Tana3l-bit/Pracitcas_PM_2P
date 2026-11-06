import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/publicacion.dart';

class ItemPublicacion extends StatelessWidget {
  final Publicacion publicacion;

  const ItemPublicacion({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = DateFormat('dd/MM/yyyy - hh:mm a').format(publicacion.fecha);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(
          publicacion.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(publicacion.contenido),
            const SizedBox(height: 6),
            Text(
              fechaFormateada,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}