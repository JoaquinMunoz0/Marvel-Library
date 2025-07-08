import 'package:flutter/material.dart';

class ComicsSection extends StatelessWidget {
  final List<dynamic> comics;

  const ComicsSection({
    super.key,
    required this.comics,
  });

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;

    if (comics.isEmpty) {
      return const Text(
        'No hay cómics disponibles.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.5),
        itemCount: comics.length,
        itemBuilder: (context, index) {
          final comic = comics[index];
          final imageUrl =
              '${comic['thumbnail']['path']}/portrait_uncanny.${comic['thumbnail']['extension']}';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: background,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  imageUrl,
                  height: 280,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[900],
                      height: 280,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[900],
                    height: 280,
                    child: const Icon(Icons.broken_image, size: 80, color: Colors.white30),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    comic['title'] ?? 'Sin título',
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
          );
        },
      ),
    );
  }
}
