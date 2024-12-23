import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  askChatGPT() {
    post(Uri.parse('https://api.openai.com/v1/chat/completions'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    }, body: {
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "developer", "content": "You are a helpful assistant."},
        {"role": "user", "content": messageController.text}
      ]
    });
  }

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        title: Text(
          'Chat Screen',
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: Text('Chat Screen')),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.deepPurpleAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Bạn muốn hỏi gì hôm nay?',
                      hintStyle: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    askChatGPT();
                  },
                  splashColor: Colors.deepPurpleAccent,
                  icon: Icon(Icons.send, color: Colors.deepPurpleAccent),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
