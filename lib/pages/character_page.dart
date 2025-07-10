import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';
import 'character_detail.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> searchCharacter(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        errorMessage = 'Ingresa un nombre para buscar.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final encodedQuery = Uri.encodeQueryComponent(query);
    final url =
        'https://gateway.marvel.com/v1/public/characters?nameStartsWith=$encodedQuery&limit=20&ts=1752117618&apikey=40a835d209da33c1145163d7b5d39c76&hash=b35cb356f20d134d3fcaa4d4785e1c1d';

    try {
      final marvelService = MarvelService(url);
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      setState(() {
        searchResults = results;
        isLoading = false;
        if (results.isEmpty) {
          errorMessage = 'No se encontraron personajes con ese nombre.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Ocurrió un error al buscar: $e';
      });
    }
  }

  Widget buildCharacterCard(dynamic character) {
    final name = character['name'];
    final thumbnail = character['thumbnail'];
    final imageUrl =
        '${thumbnail['path']}/portrait_uncanny.${thumbnail['extension']}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterDetailPage(
              characterId: character['id'],
              characterName: name,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar Personaje"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: searchCharacter,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: Iron Man',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => searchCharacter(_controller.text),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final character = searchResults[index];
                  return buildCharacterCard(character);
                },
              ),
            ),
        ],
      ),
    );
  }
}
