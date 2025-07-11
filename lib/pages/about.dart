import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de la App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Marvel Viewer',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aplicacion desarrollada para explorar personajes y cómics del universo Marvel usando la API oficial de Marvel.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Funciones principales:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const BulletPoint(text: 'Buscar personajes y cómics'),
            const BulletPoint(text: 'Ver detalles de personajes y cómics'),
            const BulletPoint(text: 'Guardar favoritos'),
            const BulletPoint(text: 'Personalizar cantidad de personajes'),
            const BulletPoint(text: 'Modo oscuro por defecto'),
            const Spacer(),
            const Text(
              "Desarrollado por Equipo JoJo's - 2025",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check, size: 20, color: Colors.redAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
