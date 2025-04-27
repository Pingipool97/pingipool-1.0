import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static Future<String> sendMessage(String prompt) async {
    try {
      final url = Uri.parse('https://pingipool-backend.onrender.com/chat');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Nessuna risposta ricevuta.';
      } else {
        return 'Errore durante la comunicazione.';
      }
    } catch (e) {
      return 'Errore durante la comunicazione.';
    }
  }
}
