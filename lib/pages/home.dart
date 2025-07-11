import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';
import 'character_detail.dart';
import 'character_page.dart';
import 'profile.dart';
import 'package:marvel_lib/entities/activity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> allCharacters = [];
  List<dynamic> filteredCharacters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    const int totalCharactersMarvel = 1562;
    final int desiredCount = await ActivityPreferences.loadHeroCount();
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
        break;
      }
    }

    setState(() {
      allCharacters = personajesUnicos;
      filteredCharacters = personajesUnicos;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marvel Viewer"),
        actions: [
          // BOTON PANTALLA DE PERFIL
          
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Perfil de usuario",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(), // <-- TIENE QUE TENER ESTA CLASE JOPUTA
                ),
              );
            },
          ),
          
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
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
      floatingActionButton: FloatingActionButton(
        tooltip: "Buscar personaje",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CharacterPage(),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
