import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'pages/home.dart';
import 'theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;

    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marvel Viewer',
      theme: MarvelTheme.darkTheme,
      home: FutureBuilder<bool>(
        future: checkInternetConnection(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreen();
          } else {
            return const NoConnectionScreen();
          }
        },
      ),
    );
  }
}

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  void _retry(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyApp()),
    );
  }

  void _exitApp() {
    SystemNavigator.pop(); // Cierra la app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'Sin conexión a Internet',
              style: TextStyle(fontSize: 22, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Necesitas conexión para utilizar la app.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _retry(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _exitApp,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
