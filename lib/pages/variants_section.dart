import 'package:flutter/material.dart';

class VariantsSection extends StatefulWidget {
  final List<dynamic> variants;
  final String baseCharacterName;
  final void Function(BuildContext, Map<String, dynamic>) onVariantTap;

  const VariantsSection({
    super.key,
    required this.variants,
    required this.baseCharacterName,
    required this.onVariantTap,
  });

  @override
  State<VariantsSection> createState() => _VariantsSectionState();
}

class _VariantsSectionState extends State<VariantsSection> {
  late final PageController _pageController;

  static const int _infiniteScrollMultiplier = 1000;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.variants.length * (_infiniteScrollMultiplier ~/ 2);
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

  String getVariantLabel(String fullName, String baseName) {
    if (fullName == baseName) return '';
    final cleanBase = baseName.trim().toLowerCase();
    final cleanFull = fullName.trim().toLowerCase();
    if (cleanFull.startsWith(cleanBase)) {
      return fullName.substring(baseName.length).trim();
    }
    return fullName;
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;

    if (widget.variants.length <= 1) {
      return const Text(
        'No hay variantes disponibles.',
        style: TextStyle(color: Colors.white),
      );
    }

    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.variants.length * _infiniteScrollMultiplier,
        itemBuilder: (context, index) {
          final variant = widget.variants[index % widget.variants.length];
          final imageUrl =
              '${variant['thumbnail']['path']}/portrait_uncanny.${variant['thumbnail']['extension']}';
          final variantLabel = getVariantLabel(variant['name'], widget.baseCharacterName);

          return GestureDetector(
            onTap: () => widget.onVariantTap(context, variant),
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
                      variantLabel.isEmpty ? '(Variante)' : variantLabel,
                      maxLines: 1,
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
                          )
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
