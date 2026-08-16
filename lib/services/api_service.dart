import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static Future<Map<String, dynamic>> obtenerFinanciamientos() async {
    final url = Uri.parse('$baseUrl/api/financiamientos');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Error HTTP ${response.statusCode}: ${response.body}',
    );
  }
}