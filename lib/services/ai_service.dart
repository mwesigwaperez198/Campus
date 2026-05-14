import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  // Replace with your actual AI Image Generation API endpoint (e.g., OpenAI DALL-E, Midjourney API, or custom backend)
  final String _apiEndpoint = "https://api.openai.com/v1/images/generations";
  String get _apiKey => dotenv.get('OPENAI_API_KEY', fallback: '');

  Future<String?> generateImage(String prompt) async {
    if (_apiKey.isEmpty || _apiKey == "your_openai_api_key_here") {
      debugPrint("AI Image Error: OpenAI API Key is not configured in .env");
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": "Makerere University context: $prompt",
          "n": 1,
          "size": "1024x1024",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['url'];
      } else {
        debugPrint("AI Image Error: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("AI Image Exception: $e");
      return null;
    }
  }
}
