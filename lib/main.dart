import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'theme/theme.dart';

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
      home: const HomeScreen(),
    );
  }
}
