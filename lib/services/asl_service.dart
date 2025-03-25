import 'package:http/http.dart' as http;
import 'dart:convert';

class ASLService {
  static const String _baseUrl = 'http://192.168.1.9:5000';

  static Future<String> preprocessText(String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/preprocess'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['processed_message'];
    } else {
      throw Exception('Failed to preprocess text');
    }
  }

  // Add other service methods as needed, e.g., for handling audio files
}
