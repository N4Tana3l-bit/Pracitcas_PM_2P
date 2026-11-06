import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificaciones {
  static final plugin = FlutterLocalNotificationsPlugin();

  static Future<void> iniciar() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings: settings);

    // Solicitud de permiso en Android 13+
    final androidImplementation = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> mostrar(String titulo, String cuerpo) async {
    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'canal_practica',
        'Práctica móvil',
        channelDescription: 'Alertas de la aplicación',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await plugin.show(id: 1, title: titulo, body: cuerpo, notificationDetails: detalles);
  }
}