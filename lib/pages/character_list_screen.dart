import 'package:flutter/material.dart';
import 'character_detail.dart';  // Importa la nueva pantalla

class CharacterListScreen extends StatelessWidget {
  final List<dynamic> characters;

  const CharacterListScreen({super.key, required this.characters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todos los personajes")),
      body: ListView.builder(
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
                  builder: (context) => CharacterDetailPage(
                    characterId: character['id'],
                    characterName: name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
