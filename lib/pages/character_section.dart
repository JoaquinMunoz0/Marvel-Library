import 'package:flutter/material.dart';
import 'character_detail.dart';

class CharacterAppearancesSection extends StatelessWidget {
  final List<dynamic> characters;
  final void Function(BuildContext context, Map<String, dynamic> character)? onCharacterTap;

  const CharacterAppearancesSection({
    super.key,
    required this.characters,
    this.onCharacterTap,
  });

  void _navigateToCharacter(BuildContext context, Map<String, dynamic> character) {
    if (onCharacterTap != null) {
      onCharacterTap!(context, character);
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return const Text(
        'No hay personajes disponibles.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.5),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          final imageUrl =
              '${character['thumbnail']['path']}/portrait_uncanny.${character['thumbnail']['extension']}';

          return GestureDetector(
            onTap: () => _navigateToCharacter(context, character),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    imageUrl,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 280,
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, size: 80, color: Colors.white30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      character['name'] ?? 'Sin nombre',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
