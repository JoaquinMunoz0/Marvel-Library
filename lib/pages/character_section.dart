import 'package:flutter/material.dart';
import 'character_detail.dart';

class CharacterAppearancesSection extends StatefulWidget {
  final List<dynamic> characters;
  final void Function(BuildContext context, Map<String, dynamic> character)? onCharacterTap;

  const CharacterAppearancesSection({
    super.key,
    required this.characters,
    this.onCharacterTap,
  });

  @override
  State<CharacterAppearancesSection> createState() => _CharacterAppearancesSectionState();
}

class _CharacterAppearancesSectionState extends State<CharacterAppearancesSection> {
  late final PageController _pageController;
  static const int _infiniteScrollMultiplier = 1000;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.characters.length * (_infiniteScrollMultiplier ~/ 2);
    _pageController = PageController(
      viewportFraction: 0.5,
      initialPage: initialPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToCharacter(BuildContext context, Map<String, dynamic> character) {
    if (widget.onCharacterTap != null) {
      widget.onCharacterTap!(context, character);
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
    if (widget.characters.isEmpty) {
      return const Text(
        'No hay personajes disponibles.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.characters.length * _infiniteScrollMultiplier,
        itemBuilder: (context, index) {
          final character = widget.characters[index % widget.characters.length];
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
