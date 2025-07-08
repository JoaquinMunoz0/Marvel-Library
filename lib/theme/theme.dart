import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarvelTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Colors.redAccent,
        secondary: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: GoogleFonts.bebasNeueTextTheme(
        const TextTheme().apply(bodyColor: Colors.white),
      ),
      useMaterial3: true,
    );
  }
}
