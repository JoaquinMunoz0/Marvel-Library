import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';
import 'variantes_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> characters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
  final offsets = [0, 200, 400, 600, 800]; // Puedes cambiar o ampliar
  List<dynamic> allCharacters = [];

  try {
    for (final offset in offsets) {
      final url =
          'https://gateway.marvel.com/v1/public/characters?limit=100&offset=$offset&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198';

      final marvelService = MarvelService(url);
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      allCharacters.addAll(results);
    }

    // Aquí aplicamos el filtro para evitar mostrar variantes
    Set<String> nombreBasesVistos = {};
    List<dynamic> filtrados = [];

    for (var personaje in allCharacters) {
      String nombre = personaje['name'];
      // Cortamos el nombre base antes del paréntesis si existe
      String nombreBase = nombre.contains('(')
          ? nombre.split('(')[0].trim()
          : nombre.trim();

      if (!nombreBasesVistos.contains(nombreBase)) {
        nombreBasesVistos.add(nombreBase);
        filtrados.add(personaje);
      }
    }

    setState(() {
      characters = filtrados;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error fetching characters: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personajes Marvel")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                final name = character['name'];
                final thumbnail = character['thumbnail'];
                final imageUrl =
                    '${thumbnail['path']}/standard_fantastic.${thumbnail['extension']}';

                return ListTile(
                  leading: Image.network(imageUrl),
                  title: Text(name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VariantesPage(baseName: name),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
