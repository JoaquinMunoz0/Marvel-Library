import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';
import 'character_detail.dart';
import 'comics_detail.dart';

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
  String searchType = 'personaje'; // personaje o comic

  Future<void> searchMarvel(String query) async {
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
    final isCharacter = searchType == 'personaje';
    final url = isCharacter
        ? 'https://gateway.marvel.com/v1/public/characters?nameStartsWith=$encodedQuery&limit=20&ts=1752117618&apikey=40a835d209da33c1145163d7b5d39c76&hash=b35cb356f20d134d3fcaa4d4785e1c1d'
        : 'https://gateway.marvel.com/v1/public/comics?titleStartsWith=$encodedQuery&limit=20&ts=1752117618&apikey=40a835d209da33c1145163d7b5d39c76&hash=b35cb356f20d134d3fcaa4d4785e1c1d';

    try {
      final marvelService = MarvelService(url);
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      setState(() {
        searchResults = results;
        isLoading = false;
        if (results.isEmpty) {
          errorMessage = 'No se encontraron resultados con ese nombre.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Ocurrió un error al buscar: $e';
      });
    }
  }

  Widget buildResultCard(dynamic item) {
    final isCharacter = searchType == 'personaje';
    final name = isCharacter ? item['name'] : item['title'];
    final thumbnail = item['thumbnail'];
    final imageUrl = '${thumbnail['path']}/portrait_uncanny.${thumbnail['extension']}';

    return GestureDetector(
      onTap: () {
        if (isCharacter) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailPage(
                characterId: item['id'],
                characterName: item['name'],
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComicDetailPage(
                comicId: item['id'],
                comicTitle: item['title'],
              ),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      appBar: AppBar(title: const Text("Buscar en Marvel")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: searchMarvel,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: searchType == 'personaje' ? 'Ej: Iron Man' : 'Ej: Civil War',
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
                      onPressed: () => searchMarvel(_controller.text),
                      child: const Text('Buscar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Personajes'),
                      selected: searchType == 'personaje',
                      onSelected: (selected) {
                        setState(() {
                          searchType = 'personaje';
                          searchResults.clear();
                          _controller.clear();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Cómics'),
                      selected: searchType == 'comic',
                      onSelected: (selected) {
                        setState(() {
                          searchType = 'comic';
                          searchResults.clear();
                          _controller.clear();
                        });
                      },
                    ),
                  ],
                )
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
                  final item = searchResults[index];
                  return buildResultCard(item);
                },
              ),
            ),
        ],
      ),
    );
  }
}
