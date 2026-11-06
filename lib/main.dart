import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuntosInteresPage(),
    ));

class PuntoInteres {
  final String nombre;
  final double latitud;
  final double longitud;

  PuntoInteres({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });
}

class PuntosInteresPage extends StatefulWidget {
  const PuntosInteresPage({super.key});

  @override
  State<PuntosInteresPage> createState() => _PuntosInteresPageState();
}

class _PuntosInteresPageState extends State<PuntosInteresPage> {
  Position? _posicionActual;
  String _estado = 'Obteniendo GPS...';
  final _nombreCtrl = TextEditingController();

  final List<PuntoInteres> _puntos = [
    PuntoInteres(nombre: 'Catedral San Francisco', latitud: 19.8464, longitud: -90.5361),
    PuntoInteres(nombre: 'Plaza Principal', latitud: 19.8458, longitud: -90.5352),
    PuntoInteres(nombre: 'Fuerte de San Miguel', latitud: 19.8242, longitud: -90.5739),
  ];

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
  }

  Future<void> _obtenerUbicacionActual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _estado = 'Servicio de ubicación desactivado');
      return;
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      setState(() => _estado = 'Sin permisos de ubicación');
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _posicionActual = pos;
      _estado = 'Ubicación actualizada';
    });
  }

  String _calcularDistancia(double lat, double lng) {
    if (_posicionActual == null) return 'Calculando...';
    double metros = Geolocator.distanceBetween(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      lat,
      lng,
    );

    if (metros >= 1000) {
      return '${(metros / 1000).toStringAsFixed(2)} km';
    }
    return '${metros.toStringAsFixed(0)} m';
  }

  Future<void> _abrirEnMapa(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _guardarUbicacionActual() {
    if (_posicionActual == null) return;
    if (_nombreCtrl.text.trim().isEmpty) return;

    setState(() {
      _puntos.add(PuntoInteres(
        nombre: _nombreCtrl.text.trim(),
        latitud: _posicionActual!.latitude,
        longitud: _posicionActual!.longitude,
      ));
      _nombreCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos de Interés (GPS)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _obtenerUbicacionActual,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_estado, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (_posicionActual != null)
                            Text(
                              'Lat: ${_posicionActual!.latitude.toStringAsFixed(4)}, '
                              'Lng: ${_posicionActual!.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del punto actual',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _guardarUbicacionActual,
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Guardar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Ubicaciones Registradas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _puntos.length,
                itemBuilder: (context, i) {
                  final p = _puntos[i];
                  final distancia = _calcularDistancia(p.latitud, p.longitud);

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.place)),
                      title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Lat: ${p.latitud}, Lng: ${p.longitud}\nDistancia: $distancia'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.map, color: Colors.green),
                        onPressed: () => _abrirEnMapa(p.latitud, p.longitud),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}