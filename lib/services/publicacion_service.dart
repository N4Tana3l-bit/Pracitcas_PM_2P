import '../models/publicacion.dart';

class PublicacionService {
  Future<List<Publicacion>> obtenerPublicaciones() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Publicacion(
        id: 1,
        titulo: 'Refactorización de Arquitectura',
        contenido: 'Separación modular de capas utilizando Provider y buenas prácticas.',
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Publicacion(
        id: 2,
        titulo: 'Optimización en Flutter',
        contenido: 'Uso de widgets const, ListView.builder y reconstrucción selectiva.',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}