import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/publicacion_provider.dart';
import 'screens/feed_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PublicacionProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FeedScreen(),
      ),
    ),
  );
}