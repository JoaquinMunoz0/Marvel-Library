import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'pages/home.dart';
import 'theme/theme.dart';
import 'pages/about.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marvel Viewer',
      theme: MarvelTheme.darkTheme,
      routes: {
        '/about': (context) => const AboutPage(),
      },
      home: const SplashScreen(),
    );
  }
}

// SPLASH PERSONALIZADO
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 3));

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;

    bool internetOk = false;
    if (hasConnection) {
      try {
        final result = await InternetAddress.lookup('example.com');
        internetOk = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        internetOk = false;
      }
    }

    if (!mounted) return;

if (internetOk) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );
} else {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const.        NoConnectionScreen()),
   );
}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Image.asset(
            'assets/icons/iconoDefinitivo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
