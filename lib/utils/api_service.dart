import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class ApiService {
  Future<List<dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/$endpoint'));

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      return decodedResponse['result'];
    } else {
      throw Exception('Failed to load data from $endpoint');
    }
  }
}
