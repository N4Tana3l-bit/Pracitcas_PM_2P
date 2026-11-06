import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/publicacion_provider.dart';
import '../widgets/item_publicacion.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PublicacionProvider>().cargarPublicaciones());
  }

  void _mostrarModalCrear(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nueva Publicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: _contenidoCtrl, decoration: const InputDecoration(labelText: 'Contenido')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_tituloCtrl.text.isNotEmpty && _contenidoCtrl.text.isNotEmpty) {
                  context.read<PublicacionProvider>().agregarPublicacion(
                        _tituloCtrl.text.trim(),
                        _contenidoCtrl.text.trim(),
                      );
                  _tituloCtrl.clear();
                  _contenidoCtrl.clear();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Publicar'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluación: Arquitectura & Provider')),
      body: Consumer<PublicacionProvider>(
        builder: (context, provider, child) {
          if (provider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.publicaciones.isEmpty) {
            return const Center(child: Text('No hay publicaciones'));
          }
          return ListView.builder(
            itemCount: provider.publicaciones.length,
            itemBuilder: (context, index) {
              return ItemPublicacion(publicacion: provider.publicaciones[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarModalCrear(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}