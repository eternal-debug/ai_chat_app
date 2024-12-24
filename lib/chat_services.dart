import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatServices {
  askChatGPT(List<Map<String, String>> chatData) async {
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

  generateImages(String prompt) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final response = await post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      // body: jsonEncode({
      //   "model": "dall-e-2",
      //   "prompt": prompt,
      //   "n": 2,
      //   "size": "256x256",
      // }),
      body: jsonEncode({
        "model": "dall-e-3",
        "prompt": prompt,
        "size": "1024x1024",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // List<String> imageUrls = [];
      // for (var item in data['data']) {
      //   imageUrls.add(item['url']);
      // }
      // return imageUrls;
      return data['data'][0]['url'];
    } else {
      return 'Đã có lỗi xảy ra!';
    }
  }
}
