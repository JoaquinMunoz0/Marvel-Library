import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/marvel_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MarvelService marvelService = MarvelService(
    'https://gateway.marvel.com/v1/public/characters?nameStartsWith=Spider&ts=1751646862&apikey=40a835d209da33c1145163d7b5d39c76&hash=4c3e7bd19192e001f5258e8a7c5f2397',
  );

  List<dynamic> characters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    try {
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      setState(() {
        characters = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching characters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marvel Characters")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                );
              },
            ),
    );
  }
}
