import 'package:flutter/material.dart';

class ComicsSection extends StatefulWidget {
  final List<dynamic> comics;
  final void Function(BuildContext context, Map<String, dynamic> comic)? onComicTap;

  const ComicsSection({
    super.key,
    required this.comics,
    this.onComicTap,
  });

  @override
  State<ComicsSection> createState() => _ComicsSectionState();
}

class _ComicsSectionState extends State<ComicsSection> {
  late final PageController _pageController;

  static const int _infiniteScrollMultiplier = 1000;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.comics.length * (_infiniteScrollMultiplier ~/ 2);
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

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;

    if (widget.comics.isEmpty) {
      return const Text(
        'No hay cómics disponibles.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.comics.length * _infiniteScrollMultiplier,
        itemBuilder: (context, index) {
          final comic = widget.comics[index % widget.comics.length];
          final imageUrl =
              '${comic['thumbnail']['path']}/portrait_uncanny.${comic['thumbnail']['extension']}';

          return GestureDetector(
            onTap: () {
              if (widget.onComicTap != null) {
                widget.onComicTap!(context, comic);
              }
            },
            child: Container(
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
            ),
          );
        },
      ),
    );
  }
}
