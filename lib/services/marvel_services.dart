import 'package:http/http.dart' as http;

class MarvelService {
  final String url;

  MarvelService(this.url);

  Future<String> getMarvelData() async {
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load Marvel data.');
    }
  }
}
