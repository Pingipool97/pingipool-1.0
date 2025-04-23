import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  static const String baseUrl = 'https://pingipool-backend.onrender.com/generate-image';

  static Future<String?> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageUrl'];
      } else {
        print('Errore API: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Errore generazione immagine: $e');
      return null;
    }
  }
}
