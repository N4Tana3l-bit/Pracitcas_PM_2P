import 'package:flutter/foundation.dart';
import '../models/publicacion.dart';
import '../services/publicacion_service.dart';

class PublicacionProvider extends ChangeNotifier {
  final PublicacionService _service = PublicacionService();
  List<Publicacion> _publicaciones = [];
  bool _cargando = false;

  List<Publicacion> get publicaciones => _publicaciones;
  bool get cargando => _cargando;

  Future<void> cargarPublicaciones() async {
    _cargando = true;
    notifyListeners();
    _publicaciones = await _service.obtenerPublicaciones();
    _cargando = false;
    notifyListeners();
  }

  void agregarPublicacion(String titulo, String contenido) {
    final nueva = Publicacion(
      id: _publicaciones.length + 1,
      titulo: titulo,
      contenido: contenido,
      fecha: DateTime.now(),
    );
    _publicaciones.insert(0, nueva);
    notifyListeners();
  }
}