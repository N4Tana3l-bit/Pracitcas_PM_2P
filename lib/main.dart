import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SensoresPage(),
    ));

class SensoresPage extends StatefulWidget {
  const SensoresPage({super.key});

  @override
  State<SensoresPage> createState() => _SensoresPageState();
}

class _SensoresPageState extends State<SensoresPage> {
  XFile? foto;
  double x = 0, y = 0, z = 0;

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen((e) {
      if (mounted) {
        setState(() {
          x = e.x;
          y = e.y;
          z = e.z;
        });
      }
    });
  }

  Future<void> tomarFoto() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (f != null && mounted) {
      setState(() => foto = f);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Cámara y acelerómetro')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FilledButton.icon(
              onPressed: tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar fotografía'),
            ),
            const SizedBox(height: 12),
            if (foto != null) Image.file(File(foto!.path), height: 250),
            const Divider(height: 32),
            Text('Acelerómetro X: ${x.toStringAsFixed(2)}'),
            Text('Acelerómetro Y: ${y.toStringAsFixed(2)}'),
            Text('Acelerómetro Z: ${z.toStringAsFixed(2)}'),
          ],
        ),
      );
}