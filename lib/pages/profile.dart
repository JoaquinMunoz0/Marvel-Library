import 'package:flutter/material.dart';
import 'package:marvel_lib/entities/activity.dart';
import 'character_detail.dart';
import 'comics_detail.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Timer? _debounce;//timer para cambio de nombre

  int currentValue = 30; // VALOR INICIAL PARA LA CANTIDAD DE HEROES A MOSTRAR EN EL HOME

  List<dynamic> favoriteHeroes = []; // LISTA DE HEROES FAVORITOS
  List<dynamic> favoriteComics = []; // LISTA DE COMICS FAVORITOS

  @override
  void initState() {
    super.initState();
    _loadPreferences();

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onNameChanged() {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 800), () async {
    final name = _nameController.text.trim();
    await ActivityPreferences.saveUsername(name);
  });
}

  // CARAGA LAS PREFERENCIAS EN EL ALMACENAMIENTO
  Future<void> _loadPreferences() async {
    final value = await ActivityPreferences.loadHeroCount();
    final name = await ActivityPreferences.loadUsername();
    final favs = await ActivityPreferences.loadFavoriteCharacters();
    final favComics = await ActivityPreferences.loadFavoriteComics();

    setState(() {
      currentValue = value;
      _controller.text = value.toString();
      _nameController.text = name;
      favoriteHeroes = favs;
      favoriteComics = favComics;
    });
  }

  // GUARDA LAS PREFERENCIAS
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final int newValue = int.parse(_controller.text);
      await ActivityPreferences.saveHeroCount(newValue);
      await ActivityPreferences.saveUsername(_nameController.text.trim());

      // MENSAJE DE CONFIRMACION PARA EL USUARIO
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferencias guardadas')),
      );
    }
  }

  // NAVEGACION A LA PANTALLA DE COMIC
  void _navigateToComicDetail(Map<String, dynamic> comic) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'),
        actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'Acerca de la app',
          onPressed: () {
            Navigator.pushNamed(context, '/about');
          },
        ),
      ],
      ),
      // SAFE AREA
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Avatar del usuario
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 12),

              // INGRESAR NOMBRE DE USUARIO
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ingresa tu nombre',
                ),
              ),
              const SizedBox(height: 24),

              // CARD DE HEROES
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Héroes favoritos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // SI NO HAY HEROES FAVORITOS
                      favoriteHeroes.isEmpty
                          ? const Text('Aun no tienes Heroes Favoritos')
                          : SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: favoriteHeroes.length,
                                itemBuilder: (context, index) {
                                  final hero = favoriteHeroes[index];
                                  final imageUrl =
                                      '${hero['thumbnail']['path']}/portrait_uncanny.${hero['thumbnail']['extension']}';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CharacterDetailPage(
                                            characterId: hero['id'],
                                            characterName: hero['name'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              height: 180,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Container(
                                                height: 180,
                                                color: Colors.grey[900],
                                                child: const Icon(Icons.broken_image,
                                                    size: 50, color: Colors.white30),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            hero['name'] ?? 'Sin nombre',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // CARD DE COMICS FAVORITOS
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cómics favoritos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // SI NO HAY COMICS FAVORItOS
                      favoriteComics.isEmpty
                          ? const Text('Aun no tienes comics favoritos')
                          : SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: favoriteComics.length,
                                itemBuilder: (context, index) {
                                  final comic = favoriteComics[index];
                                  final imageUrl =
                                      '${comic['thumbnail']['path']}/portrait_uncanny.${comic['thumbnail']['extension']}';

                                  return GestureDetector(
                                    onTap: () {
                                      _navigateToComicDetail(comic);
                                    },
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              height: 180,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Container(
                                                height: 180,
                                                color: Colors.grey[900],
                                                child: const Icon(Icons.broken_image,
                                                    size: 50, color: Colors.white30),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            comic['title'] ?? 'Sin título',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PREFERENCIAS DEL HOME (cantidad de PERSONAJES a mostrar)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preferencias de inicio',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Cantidad de héroes a mostrar (1–50)',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),

                        // INGRESAR CANTIDAD DE HEROES
                        TextFormField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Ej: 30',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa un número';
                            final int? number = int.tryParse(value);
                            if (number == null) return 'Debe ser un número válido';
                            if (number < 1 || number > 50) return 'Debe estar entre 1 y 50';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // BOTON PARA GUARDAR PREFERENCIAS
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
