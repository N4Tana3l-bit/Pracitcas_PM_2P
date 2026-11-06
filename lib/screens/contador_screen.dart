import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contador_provider.dart';
import '../widgets/tarjeta_contador.dart';

class ContadorScreen extends StatelessWidget {
  const ContadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Práctica 07: Arquitectura & Provider'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TarjetaContador(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            onPressed: () => context.read<ContadorProvider>().incrementar(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'btn2',
            backgroundColor: Colors.redAccent,
            onPressed: () => context.read<ContadorProvider>().reiniciar(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}