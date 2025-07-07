import 'package:flutter/material.dart';
import 'package:marvel_lib/pages/histories_pages.dart';
import 'dart:convert';
import '../services/marvel_services.dart';

class VariantesPage extends StatefulWidget {
  final String baseName;

  const VariantesPage({super.key, required this.baseName});

  @override
  State<VariantesPage> createState() => _VariantesPageState();
}

class _VariantesPageState extends State<VariantesPage> {
  List<dynamic> variantes = [];
  bool isLoading = true;

  late final MarvelService marvelService;

  @override
  void initState() {
    super.initState();
    // Creamos el servicio con el nombre base
    marvelService = MarvelService(
      'https://gateway.marvel.com/v1/public/characters?nameStartsWith=${Uri.encodeComponent(widget.baseName)}&limit=100&offset=0&ts=1751930069&apikey=40a835d209da33c1145163d7b5d39c76&hash=a9641d5a746d417c9e5a8203a8c24198',
    );
    loadVariantes();
  }

  Future<void> loadVariantes() async {
    try {
      final data = await marvelService.getMarvelData();
      final json = jsonDecode(data);
      final results = json['data']['results'];

      setState(() {
        variantes = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching variants: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Variantes de ${widget.baseName}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: variantes.length,
              itemBuilder: (context, index) {
                final variant = variantes[index];
                final name = variant['name'];
                final description = variant['description'];
                final thumbnail = variant['thumbnail'];
                final imageUrl =
                    '${thumbnail['path']}/standard_fantastic.${thumbnail['extension']}';

                return ListTile(
                  leading: Image.network(imageUrl),
                  title: Text(name),
                  subtitle: description != null && description.isNotEmpty
                      ? Text(description)
                      : null,
                  onTap: () {
                  final id = variant['id'];
                  final name = variant['name'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoriesPage(
                        characterId: id,
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
