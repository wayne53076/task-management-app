import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ChatService {
  final String? _apiKey = dotenv.env['API_KEY'];
  static const String _url = 'https://api.edenai.run/v2/text/generation';

  Future<String> fetchPromptResponse(String prompt) async {

    Map data = {
      'providers': 'openai',
      'text':  "$prompt\nWith a short response",
      'temperature': 0.2,
      'max_tokens': 150
    };

    var body = json.encode(data);
    var response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': "application/json",
        'authorization': _apiKey ?? ''
      },
      body: body,
    );


    Map<String, dynamic>responseData = jsonDecode(response.body);
    String generatedText;

    if(responseData['openai'] == null || responseData['openai']['status'] != 'success') {
      generatedText = 'Failed to generate response';
    } else {
      generatedText = responseData['openai']['generated_text'].trim();
      while(generatedText[0] == ',') {
        generatedText = generatedText.substring(1, generatedText.length);
      }
    }

    return generatedText.trim();
  }

}
