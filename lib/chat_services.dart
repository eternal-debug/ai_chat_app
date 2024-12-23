import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatServices {
  Future<String> askChatGPT(List<Map<String, String>> chatData) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final response = await post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode({"model": "gpt-4o-mini", "messages": chatData}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return 'Đã có lỗi xảy ra!';
    }
  }
}
