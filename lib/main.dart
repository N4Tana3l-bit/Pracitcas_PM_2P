import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/db.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotasPage(),
    ));

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();

  List<Map<String, dynamic>> _notas = [];
  int? _notaIdEdicion;
  String _nombreUsuario = 'Invitado';

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
    _refreshNotas();
  }

  Future<void> _cargarNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreUsuario = prefs.getString('nombre_usuario') ?? 'Invitado';
    });
  }

  Future<void> _guardarNombreUsuario(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre_usuario', nombre);
    setState(() {
      _nombreUsuario = nombre;
    });
  }

  Future<void> _refreshNotas() async {
    final datos = await DB.listar();
    setState(() {
      _notas = datos;
    });
  }

  void _limpiarFormulario() {
    _tituloCtrl.clear();
    _contenidoCtrl.clear();
    _notaIdEdicion = null;
  }

  Future<void> _guardarOActualizar() async {
    if (_tituloCtrl.text.trim().isEmpty || _contenidoCtrl.text.trim().isEmpty) return;

    if (_notaIdEdicion == null) {
      await DB.insertar(_tituloCtrl.text, _contenidoCtrl.text);
    } else {
      await DB.actualizar(_notaIdEdicion!, _tituloCtrl.text, _contenidoCtrl.text);
    }

    _limpiarFormulario();
    _refreshNotas();
  }

  Future<void> _eliminarNota(int id) async {
    await DB.eliminar(id);
    _refreshNotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas de $_nombreUsuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _nombreCtrl.text = _nombreUsuario;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Preferencias de Usuario'),
                  content: TextField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _guardarNombreUsuario(_nombreCtrl.text.trim());
                        Navigator.pop(ctx);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _contenidoCtrl,
              decoration: const InputDecoration(labelText: 'Contenido'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardarOActualizar,
                    child: Text(_notaIdEdicion == null ? 'Guardar' : 'Actualizar'),
                  ),
                ),
                if (_notaIdEdicion != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(_limpiarFormulario),
                    child: const Text('Cancelar'),
                  ),
                ]
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _notas.length,
                itemBuilder: (context, i) {
                  final n = _notas[i];
                  return ListTile(
                    title: Text(n['titulo']),
                    subtitle: Text(n['contenido']),
                    onTap: () {
                      setState(() {
                        _notaIdEdicion = n['id'];
                        _tituloCtrl.text = n['titulo'];
                        _contenidoCtrl.text = n['contenido'];
                      });
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar Nota'),
                            content: const Text('¿Deseas eliminar esta nota?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _eliminarNota(n['id']);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                      },
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