import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';

class HistoriesPage extends StatefulWidget {
  final int characterId;
  final String characterName;

  const HistoriesPage({
    super.key,
    required this.characterId,
    required this.characterName,
  });

  @override
  State<HistoriesPage> createState() => _HistoriesPageState();
}

class _HistoriesPageState extends State<HistoriesPage> {
  List<dynamic> comics = [];
  bool isLoading = true;

  late final MarvelService marvelService;

  @override
  void initState() {
    super.initState();
    marvelService = MarvelService(
      'https://gateway.marvel.com/v1/public/characters/${widget.characterId}/comics?limit=100&offset=0',
    );
    loadComics();
  }

  Future<void> loadComics() async {
    try {
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      setState(() {
        comics = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching comics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cómics de ${widget.characterName}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : comics.isEmpty
              ? const Center(child: Text("No hay cómics disponibles."))
              : ListView.builder(
                  itemCount: comics.length,
                  itemBuilder: (context, index) {
                    final comic = comics[index];
                    final title = comic['title'];
                    final description = comic['description'] ?? 'Sin descripción';
                    final thumbnail = comic['thumbnail'];
                    final imageUrl =
                        '${thumbnail['path']}/portrait_uncanny.${thumbnail['extension']}';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: Image.network(imageUrl, width: 60, fit: BoxFit.cover),
                        title: Text(title),
                        subtitle: Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
