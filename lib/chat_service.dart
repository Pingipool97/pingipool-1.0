import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  // Funzione già esistente per risposta testuale
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

  // Funzione per generare immagini AI
  static Future<String?> generateImage(String prompt) async {
    try {
      final url = Uri.parse('http://localhost:10000/generate-image');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Immagine AI: ${data['imageUrl']}');
        return data['imageUrl'];
      } else {
        debugPrint('❌ Errore AI: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Eccezione AI: $e');
      return null;
    }
  }

  // Funzione per cercare immagini reali tramite Google CSE con filtro dominio
  static Future<String?> fetchRealImage(String query) async {
    try {
      const apiKey = 'AIzaSyB_zfFN-k_NOO_5ep6i5wTGBtBpMv4Bi0U';
      const cseId = '66fb5531ab66b4547';

      final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?q=${Uri.encodeComponent(query)}&cx=$cseId&searchType=image&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>?;

        if (items != null) {
          for (final item in items) {
            final link = item['link'] as String?;
            if (link != null && !_isBlockedDomain(link)) {
              debugPrint('✅ URL immagine reale filtrata: $link');
              return link;
            }
          }
        }

        debugPrint('❌ Nessuna immagine valida trovata');
        return null;
      } else {
        debugPrint('❌ Errore risposta Google: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Eccezione Google Search: $e');
      return null;
    }
  }

  // Blocca domini noti per dare errore
  static bool _isBlockedDomain(String url) {
    final blocked = ["reddit.com", "redd.it", "imgur.com"];
    return blocked.any((domain) => url.contains(domain));
  }
}
