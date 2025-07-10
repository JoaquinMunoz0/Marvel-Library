import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  const int totalCharactersMarvel = 1562;
  final prefs = await SharedPreferences.getInstance();
  final int desiredCount = prefs.getInt('heroCount') ?? 30;
  const int maxAttempts = 10;
  const int limitPerCall = 100;

  Set<String> nombreBasesVistos = {};
  List<dynamic> personajesUnicos = [];

  int attempts = 0;

  setState(() {
    isLoading = true;
  });

  while (personajesUnicos.length < desiredCount && attempts < maxAttempts) {
    attempts++;
    final offset = (DateTime.now().millisecondsSinceEpoch + attempts * 777) %
        (totalCharactersMarvel - limitPerCall);

    final url =
        'https://gateway.marvel.com/v1/public/characters?limit=$limitPerCall&offset=$offset&ts=1752117884&apikey=40a835d209da33c1145163d7b5d39c76&hash=18a95e3d649ebb36a0fb101234f189dc';

    try {
      final marvelService = MarvelService(url);
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      for (var personaje in results) {
        if (personajesUnicos.length >= desiredCount) break;

        String nombre = personaje['name'];
        String nombreBase = nombre.contains('(')
            ? nombre.split('(')[0].trim()
            : nombre.trim();

        if (!nombreBasesVistos.contains(nombreBase)) {
          nombreBasesVistos.add(nombreBase);
          personajesUnicos.add(personaje);
        }
      }
    } catch (e) {
      print('Error fetching characters: $e');
      break;
    }
  }

  setState(() {
    allCharacters = personajesUnicos;
    filteredCharacters = personajesUnicos;
    isLoading = false;
  });
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
