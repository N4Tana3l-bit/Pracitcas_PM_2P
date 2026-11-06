import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/contador_provider.dart';
import 'screens/contador_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ContadorProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ContadorScreen(),
      ),
    ),
  );
}