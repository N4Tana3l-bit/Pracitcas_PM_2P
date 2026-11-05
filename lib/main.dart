import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UsuariosPage(),
    ));

class Usuario {
  final int id;
  final String nombre;
  final String correo;

  Usuario({required this.id, required this.nombre, required this.correo});

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: j['id'],
        nombre: j['name'],
        correo: j['email'],
      );
}

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<List<Usuario>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = cargar();
  }

  Future<List<Usuario>> cargar() async {
    final r = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}');
    }
    final List datos = jsonDecode(r.body);
    return datos.map((e) => Usuario.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Usuarios REST')),
        body: FutureBuilder<List<Usuario>>(
          future: futuro,
          builder: (context, s) {
            if (s.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (s.hasError) {
              return Center(child: Text('Error: ${s.error}'));
            }
            final usuarios = s.data ?? [];
            return RefreshIndicator(
              onRefresh: () async => setState(() => futuro = cargar()),
              child: ListView.builder(
                itemCount: usuarios.length,
                itemBuilder: (context, i) => ListTile(
                  leading: CircleAvatar(child: Text('${usuarios[i].id}')),
                  title: Text(usuarios[i].nombre),
                  subtitle: Text(usuarios[i].correo),
                ),
              ),
            );
          },
        ),
      );
}