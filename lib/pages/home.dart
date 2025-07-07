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
  final MarvelService marvelService = MarvelService(
    'https://gateway.marvel.com/v1/public/characters?limit=100&offset=0&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
  );

  List<dynamic> characters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    try {
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      setState(() {
        characters = results;
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
