import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBTareas {
  static const _clave = 'tareas';

  static Future<List<Map<String, dynamic>>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final contenido = prefs.getString(_clave);
    if (contenido == null) return [];

    final tareas = jsonDecode(contenido) as List<dynamic>;
    return tareas
        .map((tarea) => Map<String, dynamic>.from(tarea as Map))
        .toList();
  }

  static Future<void> _guardar(List<Map<String, dynamic>> tareas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clave, jsonEncode(tareas));
  }

  static Future<void> insertar(String titulo) async {
    final tareas = await listar();
    final siguienteId = tareas.isEmpty
        ? 1
        : tareas.map((tarea) => tarea['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    tareas.add({'id': siguienteId, 'titulo': titulo, 'completada': 0});
    await _guardar(tareas);
  }

  static Future<void> actualizar(int id, String titulo) async {
    final tareas = await listar();
    for (final tarea in tareas) {
      if (tarea['id'] == id) tarea['titulo'] = titulo;
    }
    await _guardar(tareas);
  }

  static Future<void> toggleCompletada(int id, bool completada) async {
    final tareas = await listar();
    for (final tarea in tareas) {
      if (tarea['id'] == id) tarea['completada'] = completada ? 1 : 0;
    }
    await _guardar(tareas);
  }

  static Future<void> eliminar(int id) async {
    final tareas = await listar();
    tareas.removeWhere((tarea) => tarea['id'] == id);
    await _guardar(tareas);
  }
}

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TareasPage(),
    ));

class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final _tareaCtrl = TextEditingController();
  List<Map<String, dynamic>> _todasLasTareas = [];
  String _filtro = 'todas'; // 'todas', 'pendientes', 'completadas'

  @override
  void initState() {
    super.initState();
    _cargarFiltroPreferencia();
    _cargarTareas();
  }

  Future<void> _cargarFiltroPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _filtro = prefs.getString('filtro_tareas') ?? 'todas';
    });
  }

  Future<void> _guardarFiltroPreferencia(String nuevoFiltro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filtro_tareas', nuevoFiltro);
    setState(() {
      _filtro = nuevoFiltro;
    });
  }

  Future<void> _cargarTareas() async {
    final datos = await DBTareas.listar();
    setState(() {
      _todasLasTareas = datos;
    });
  }

  List<Map<String, dynamic>> get _tareasFiltradas {
    if (_filtro == 'pendientes') {
      return _todasLasTareas.where((t) => t['completada'] == 0).toList();
    } else if (_filtro == 'completadas') {
      return _todasLasTareas.where((t) => t['completada'] == 1).toList();
    }
    return _todasLasTareas;
  }

  Future<void> _agregarTarea() async {
    if (_tareaCtrl.text.trim().isEmpty) return;
    await DBTareas.insertar(_tareaCtrl.text.trim());
    _tareaCtrl.clear();
    _cargarTareas();
  }

  void _editarDialog(int id, String tituloActual) {
    final editCtrl = TextEditingController(text: tituloActual);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: TextField(controller: editCtrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (editCtrl.text.trim().isNotEmpty) {
                await DBTareas.actualizar(id, editCtrl.text.trim());
                _cargarTareas();
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _tareasFiltradas;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Tareas Offline'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filtro,
            onSelected: (val) => _guardarFiltroPreferencia(val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'todas', child: Text('Mostrar Todas')),
              const PopupMenuItem(value: 'pendientes', child: Text('Solo Pendientes')),
              const PopupMenuItem(value: 'completadas', child: Text('Solo Completadas')),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tareaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Tarea',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarTarea,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: lista.isEmpty
                  ? const Center(child: Text('No hay tareas registradas'))
                  : ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (context, i) {
                        final t = lista[i];
                        final bool completada = t['completada'] == 1;
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: completada,
                              onChanged: (val) async {
                                await DBTareas.toggleCompletada(t['id'], val ?? false);
                                _cargarTareas();
                              },
                            ),
                            title: Text(
                              t['titulo'],
                              style: TextStyle(
                                decoration: completada ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarDialog(t['id'], t['titulo']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await DBTareas.eliminar(t['id']);
                                    _cargarTareas();
                                  },
                                ),
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