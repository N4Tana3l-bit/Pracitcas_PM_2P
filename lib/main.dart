import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'services/notificacion_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notificaciones.iniciar();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IncidenciasPage(),
  ));
}

class IncidenciasPage extends StatefulWidget {
  const IncidenciasPage({super.key});

  @override
  State<IncidenciasPage> createState() => _IncidenciasPageState();
}

class _IncidenciasPageState extends State<IncidenciasPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _categoria = 'Mantenimiento';
  String? _fotoPath;
  Position? _posicion;
  Database? _db;
  List<Map<String, dynamic>> _reportes = [];

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  Future<void> _initDB() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'incidencias.db'),
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE reportes (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, descripcion TEXT, categoria TEXT, foto TEXT, lat REAL, lng TEXT)',
      ),
    );
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    if (_db == null) return;
    final res = await _db!.query('reportes', orderBy: 'id DESC');
    setState(() => _reportes = res);
  }

  Future<void> _capturarFoto() async {
    final f = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 75);
    if (f != null) setState(() => _fotoPath = f.path);
  }

  Future<void> _obtenerGPS() async {
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.whileInUse || permiso == LocationPermission.always) {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _posicion = pos);
    }
  }

  Future<void> _guardarReporte() async {
    if (!_formKey.currentState!.validate()) return;
    if (_db == null) return;

    await _db!.insert('reportes', {
      'titulo': _tituloCtrl.text.trim(),
      'descripcion': _descCtrl.text.trim(),
      'categoria': _categoria,
      'foto': _fotoPath ?? '',
      'lat': _posicion?.latitude ?? 0.0,
      'lng': _posicion?.longitude.toString() ?? '0.0',
    });

    await Notificaciones.mostrar(
      'Reporte Guardado',
      'La incidencia "${_tituloCtrl.text.trim()}" fue registrada con éxito.',
    );

    _tituloCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _fotoPath = null;
      _posicion = null;
    });
    _cargarReportes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte Móvil de Incidencias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título de la incidencia'),
                      validator: (v) => v == null || v.isEmpty ? 'Ingresa un título' : null,
                    ),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: (v) => v == null || v.isEmpty ? 'Ingresa una descripción' : null,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      items: ['Mantenimiento', 'Seguridad', 'Infraestructura']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _categoria = v!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _capturarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Foto'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _obtenerGPS,
                          icon: const Icon(Icons.location_on),
                          label: const Text('GPS'),
                        ),
                      ],
                    ),
                    if (_fotoPath != null) ...[
                      const SizedBox(height: 8),
                      Image.file(File(_fotoPath!), height: 100),
                    ],
                    if (_posicion != null)
                      Text('Coordenadas: ${_posicion!.latitude.toStringAsFixed(4)}, ${_posicion!.longitude.toStringAsFixed(4)}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _guardarReporte,
                      child: const Text('Guardar e Informar'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              const Text('Reportes Registrados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reportes.length,
                itemBuilder: (context, i) {
                  final r = _reportes[i];
                  return ListTile(
                    leading: r['foto'] != '' ? Image.file(File(r['foto']), width: 40, height: 40, fit: BoxFit.cover) : const Icon(Icons.report),
                    title: Text(r['titulo']),
                    subtitle: Text('${r['categoria']} - ${r['descripcion']}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}