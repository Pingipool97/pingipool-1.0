import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String backendUrl = 'https://pingipool-backend.onrender.com/chat'; // oppure localhost:10000 per test locali

  static Future<String> getChatResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Risposta non disponibile.';
      } else {
        return 'Errore: ${response.statusCode}';
      }
    } catch (e) {
      return 'Errore di connessione: $e';
    }
  }
}
