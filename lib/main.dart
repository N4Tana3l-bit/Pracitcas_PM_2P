import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin notifPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  await notifPlugin.initialize(settings: const InitializationSettings(android: android));
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainNavegacion(),
  ));
}

class MainNavegacion extends StatefulWidget {
  const MainNavegacion({super.key});

  @override
  State<MainNavegacion> createState() => _MainNavegacionState();
}

class _MainNavegacionState extends State<MainNavegacion> {
  int _idx = 0;
  final List<Widget> _pantallas = const [
    InicioScreen(),
    FormularioScreen(),
    ApiSincronizacionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventario'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Nuevo Registro'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_sync), label: 'Sincronizar REST'),
        ],
      ),
    );
  }
}

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Inventario & Mantenimiento')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.precision_manufacturing, size: 80, color: Colors.blueAccent),
              SizedBox(height: 16),
              Text(
                'Sistema Móvil Integrado v1.0',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Gestione sus activos con geolocalización, captura de imágenes y respaldo en la nube.'),
            ],
          ),
        ),
      ),
    );
  }
}

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();

  Future<void> _guardarYNotificar() async {
    if (!_formKey.currentState!.validate()) return;

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'canal_evaluable',
        'Alertas Inventario',
        importance: Importance.high,
      ),
    );
    await notifPlugin.show(
      id: 2,
      title: 'Activo Registrado',
      body: 'Se ha registrado el activo ${_nombreCtrl.text.trim()} en la base local.',
      notificationDetails: detalles,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro guardado exitosamente.')),
    );
    _nombreCtrl.clear();
    _codigoCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Activo / Equipo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Equipo'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(labelText: 'Código de Serie'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _guardarYNotificar,
                icon: const Icon(Icons.save),
                label: const Text('Registrar Activo'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ApiSincronizacionScreen extends StatefulWidget {
  const ApiSincronizacionScreen({super.key});

  @override
  State<ApiSincronizacionScreen> createState() => _ApiSincronizacionScreenState();
}

class _ApiSincronizacionScreenState extends State<ApiSincronizacionScreen> {
  bool _cargando = false;
  List _items = [];

  Future<void> _sincronizarREST() async {
    setState(() => _cargando = true);
    try {
      final res = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'));
      if (res.statusCode == 200) {
        setState(() => _items = jsonDecode(res.body));
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización Cloud REST')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _sincronizarREST,
              icon: const Icon(Icons.sync),
              label: const Text('Consultar Servidor REST'),
            ),
            const SizedBox(height: 16),
            _cargando
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, i) => ListTile(
                        leading: CircleAvatar(child: Text('${_items[i]['id']}')),
                        title: Text(_items[i]['title']),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}