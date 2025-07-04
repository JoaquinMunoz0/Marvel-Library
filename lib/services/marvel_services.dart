import 'package:http/http.dart' as http;

class MarvelService {
  String urlRequest;

  MarvelService(this.urlRequest);

  Future<String>getMarvel(String searchQuery) async{
    final url= Uri.parse('$urlRequest/shows?q=$searchQuery');

    final response= await http.get(url);

    if(response.statusCode ==200)
    {
      return response.body;
    }
    else{
      throw Exception('Failed to load Marvel Details.')
    }
  }


  }
  






