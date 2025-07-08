import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';
import '../utils/util.dart';
import 'character_list_screen.dart';
import 'character_detail.dart';  // Importa la nueva pantalla

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> allCharacters = [];
  List<dynamic> filteredCharacters = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    final offsets = [0, 200, 400, 600, 800];
    List<dynamic> fetched = [];

    try {
      for (final offset in offsets) {
        final url =
            'https://gateway.marvel.com/v1/public/characters?limit=100&offset=$offset&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198';

        final marvelService = MarvelService(url);
        final data = await marvelService.getMarvelData();
        final json = jsonDecode(data);
        final results = json['data']['results'];

        fetched.addAll(results);
      }

      // Filtrar por nombre base
      Set<String> nombresVistos = {};
      List<dynamic> filtrados = [];

      for (var personaje in fetched) {
        String nombre = personaje['name'];
        String nombreBase = AppUtils.cleanCharacterName(nombre);

        if (!nombresVistos.contains(nombreBase)) {
          nombresVistos.add(nombreBase);
          filtrados.add(personaje);
        }
      }

      setState(() {
        allCharacters = filtrados;
        filteredCharacters = filtrados;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      //print('Error fetching characters: $e');
    }
  }

  void filterCharacters(String query) {
    final filtered = allCharacters.where((char) {
      final name = AppUtils.cleanCharacterName(char['name']).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCharacters = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marvel Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "Ver como lista",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterListScreen(characters: allCharacters),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterCharacters,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar personaje...',
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
                Expanded(
                  child: PageView.builder(
                    itemCount: filteredCharacters.length,
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, index) {
                      final character = filteredCharacters[index];
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
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
