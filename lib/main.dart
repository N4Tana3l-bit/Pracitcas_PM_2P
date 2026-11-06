import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BitacoraPage(),
    ));

class RegistroInspeccion {
  final String fotoPath;
  final DateTime fechaHora;
  final String acelerometro;
  final String giroscopio;

  RegistroInspeccion({
    required this.fotoPath,
    required this.fechaHora,
    required this.acelerometro,
    required this.giroscopio,
  });
}

class BitacoraPage extends StatefulWidget {
  const BitacoraPage({super.key});

  @override
  State<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends State<BitacoraPage> {
  double _accX = 0, _accY = 0, _accZ = 0;
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;
  final List<RegistroInspeccion> _registros = [];

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen((e) {
      if (mounted) setState(() { _accX = e.x; _accY = e.y; _accZ = e.z; });
    });
    gyroscopeEventStream().listen((e) {
      if (mounted) setState(() { _gyroX = e.x; _gyroY = e.y; _gyroZ = e.z; });
    });
  }

  Future<void> _capturarInspeccion() async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (foto == null) return; // Manejo de cancelación

    final nuevoRegistro = RegistroInspeccion(
      fotoPath: foto.path,
      fechaHora: DateTime.now(),
      acelerometro: 'X: ${_accX.toStringAsFixed(2)}, Y: ${_accY.toStringAsFixed(2)}, Z: ${_accZ.toStringAsFixed(2)}',
      giroscopio: 'X: ${_gyroX.toStringAsFixed(2)}, Y: ${_gyroY.toStringAsFixed(2)}, Z: ${_gyroZ.toStringAsFixed(2)}',
    );

    setState(() {
      _registros.insert(0, nuevoRegistro);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de Inspección')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.blueGrey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sensores en tiempo real:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Acelerómetro: X: ${_accX.toStringAsFixed(2)} | Y: ${_accY.toStringAsFixed(2)} | Z: ${_accZ.toStringAsFixed(2)}'),
                    Text('Giroscopio: X: ${_gyroX.toStringAsFixed(2)} | Y: ${_gyroY.toStringAsFixed(2)} | Z: ${_gyroZ.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _capturarInspeccion,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Nueva Inspección'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _registros.isEmpty
                  ? const Center(child: Text('Sin registros de inspección.'))
                  : ListView.builder(
                      itemCount: _registros.length,
                      itemBuilder: (context, i) {
                        final reg = _registros[i];
                        final fechaFmt = DateFormat('dd/MM/yyyy hh:mm:ss a').format(reg.fechaHora);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(reg.fotoPath), height: 180, width: double.infinity, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 8),
                                Text('Fecha: $fechaFmt', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Acc: ${reg.acelerometro}', style: const TextStyle(fontSize: 12)),
                                Text('Gyro: ${reg.giroscopio}', style: const TextStyle(fontSize: 12)),
                              ],
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