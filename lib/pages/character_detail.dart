import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';
import 'variants_section.dart';
import 'comics_section.dart';
import 'comics_detail.dart';
import 'package:marvel_lib/entities/activity.dart';

class CharacterDetailPage extends StatefulWidget {
  final int characterId;
  final String characterName;

  const CharacterDetailPage({
    super.key,
    required this.characterId,
    required this.characterName,
  });

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  Map<String, dynamic>? characterInfo;
  List<dynamic> variantes = [];
  List<dynamic> comics = [];
  bool isLoading = true;
  bool isFavorite = false;

  late final MarvelService marvelServiceCharacter;
  late final MarvelService marvelServiceVariants;
  late final MarvelService marvelServiceComics;

  String getBaseCharacterName(String fullName) {
    return fullName.contains('(')
        ? fullName.split('(')[0].trim()
        : fullName.trim();
  }

  @override
  void initState() {
    super.initState();

    final baseName = getBaseCharacterName(widget.characterName);

    // SERVICIOS DE LA API
    marvelServiceCharacter = MarvelService(
      'https://gateway.marvel.com/v1/public/characters/${widget.characterId}?ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
    );

    marvelServiceVariants = MarvelService(
      'https://gateway.marvel.com/v1/public/characters?nameStartsWith=${Uri.encodeComponent(baseName)}&limit=100&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
    );

    marvelServiceComics = MarvelService(
      'https://gateway.marvel.com/v1/public/characters/${widget.characterId}/comics?limit=100&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
    );

    fetchAllData();
  }

  // CARGA DE INFORMACION TANTO DE PERSONAJES COMO COMICS Y FAVORITOS
  Future<void> fetchAllData() async {
    try {
      final characterDataRaw = await marvelServiceCharacter.getMarvelData();
      final characterDataJson = jsonDecode(characterDataRaw);
      final characterResults = characterDataJson['data']['results'];
      final character = characterResults.isNotEmpty ? characterResults[0] : null;

      final variantsRaw = await marvelServiceVariants.getMarvelData();
      final variantsJson = jsonDecode(variantsRaw);
      final variantsResults = variantsJson['data']['results'];

      final comicsRaw = await marvelServiceComics.getMarvelData();
      final comicsJson = jsonDecode(comicsRaw);
      final comicsResults = comicsJson['data']['results'];

      final alreadyFavorite =
          await ActivityPreferences.isFavorite(widget.characterId);

      setState(() {
        characterInfo = character;
        variantes = variantsResults
            .where((v) => v['name'] != widget.characterName)
            .toList();
        comics = comicsResults;
        isFavorite = alreadyFavorite;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // AGREGAR O ELIMINAR FAVORITOS
  Future<void> toggleFavorite() async {
    if (characterInfo == null) return;

    if (isFavorite) {
      await ActivityPreferences.removeFavoriteCharacter(widget.characterId);
    } else {
      await ActivityPreferences.addFavoriteCharacter({
        'id': widget.characterId,
        'name': widget.characterName,
        'thumbnail': characterInfo!['thumbnail'],
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  // NAVEGACION DE PANTALLA DE DETALLES PARA LAS VARIANTES
  void navigateToVariantDetail(
      BuildContext context, Map<String, dynamic> variant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterDetailPage(
          characterId: variant['id'],
          characterName: variant['name'],
        ),
      ),
    );
  }

  // NAVEGACION DE PANTALLA DE DETALLES DEL COMIC 
  void navigateToComicDetail(
      BuildContext context, Map<String, dynamic> comic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComicDetailPage(
          comicId: comic['id'],
          comicTitle: comic['title'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.characterName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            tooltip:
                isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : characterInfo == null
              ? const Center(
                  child: Text('No se encontró información del personaje.'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // IMAGEN DEL PERSONAJE
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            '${characterInfo!['thumbnail']['path']}/portrait_uncanny.${characterInfo!['thumbnail']['extension']}',
                            height: 350,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // DESCRIPCION
                      Text(
                        characterInfo!['description'].toString().isEmpty
                            ? 'Sin descripción disponible.'
                            : characterInfo!['description'],
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 24),

                      // VARIANTES DEL PERSONAJE
                      Text(
                        'Variantes',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.redAccent,
                                  fontSize: 32,
                                  fontWeight: FontWeight.normal,
                                ),
                      ),
                      const SizedBox(height: 12),
                      VariantsSection(
                        variants: variantes,
                        baseCharacterName: widget.characterName,
                        onVariantTap: navigateToVariantDetail,
                      ),
                      const SizedBox(height: 32),

                      // APARICIONES EN COMICS
                      Text(
                        'Apariciones',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.redAccent,
                                  fontSize: 32,
                                  fontWeight: FontWeight.normal,
                                ),
                      ),
                      const SizedBox(height: 12),
                      ComicsSection(
                        comics: comics,
                        onComicTap: navigateToComicDetail,
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
