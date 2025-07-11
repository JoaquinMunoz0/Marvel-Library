import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/marvel_services.dart';
import 'character_detail.dart';
import 'character_section.dart';
import 'comics_section.dart';

class ComicDetailPage extends StatefulWidget {
  final int comicId;
  final String comicTitle;

  const ComicDetailPage({
    super.key,
    required this.comicId,
    required this.comicTitle,
  });

  @override
  State<ComicDetailPage> createState() => _ComicDetailPageState();
}

class _ComicDetailPageState extends State<ComicDetailPage> {
  Map<String, dynamic>? comicInfo;
  List<dynamic> characters = [];
  List<dynamic> relatedComics = [];
  bool isLoading = true;

  late final MarvelService comicService;
  late final MarvelService charactersService;
  late final MarvelService relatedComicsService;

  String getBaseComicTitle(String fullTitle) {
    return fullTitle.contains('#') ? fullTitle.split('#')[0].trim() : fullTitle.trim();
  }

  @override
  void initState() {
    super.initState();

    final baseTitle = getBaseComicTitle(widget.comicTitle);

    comicService = MarvelService(
      'https://gateway.marvel.com/v1/public/comics/${widget.comicId}?ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
    );

    charactersService = MarvelService(
      'https://gateway.marvel.com/v1/public/comics/${widget.comicId}/characters?limit=100&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
    );

    relatedComicsService = MarvelService(
      'https://gateway.marvel.com/v1/public/comics?titleStartsWith=${Uri.encodeComponent(baseTitle)}&limit=100&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
    );

    fetchComicData();
  }

  Future<void> fetchComicData() async {
    try {
      final comicRaw = await comicService.getMarvelData();
      final comicJson = jsonDecode(comicRaw);
      final comicResults = comicJson['data']['results'];
      final comic = comicResults.isNotEmpty ? comicResults[0] : null;

      final charactersRaw = await charactersService.getMarvelData();
      final charactersJson = jsonDecode(charactersRaw);
      final charactersResults = charactersJson['data']['results'];

      final relatedRaw = await relatedComicsService.getMarvelData();
      final relatedJson = jsonDecode(relatedRaw);
      final relatedResults = relatedJson['data']['results'];

      setState(() {
        comicInfo = comic;
        characters = charactersResults;
        relatedComics = relatedResults.where((c) => c['id'] != widget.comicId).toList();
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToComic(BuildContext context, Map<String, dynamic> comic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicDetailPage(
          comicId: comic['id'],
          comicTitle: comic['title'],
        ),
      ),
    );
  }

  void navigateToCharacterDetail(BuildContext context, Map<String, dynamic> character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterDetailPage(
          characterId: character['id'],
          characterName: character['name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.comicTitle,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : comicInfo == null
              ? const Center(child: Text('No se encontró información del cómic.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            '${comicInfo!['thumbnail']['path']}/portrait_uncanny.${comicInfo!['thumbnail']['extension']}',
                            height: 350,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        comicInfo!['description']?.toString().isNotEmpty == true
                            ? comicInfo!['description']
                            : 'Sin descripción disponible.',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Otros tomos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.redAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ComicsSection(
                        comics: relatedComics,
                        onComicTap: navigateToComic,
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Apariciones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.redAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                      const SizedBox(height: 12),
                      CharacterAppearancesSection(
                        characters: characters,
                        onCharacterTap: navigateToCharacterDetail,
                      ),
                    ],
                  ),
                ),
    );
  }
}