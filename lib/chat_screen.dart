import 'package:ai_chat_app/chat_services.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String result = '';
  TextEditingController messageController = TextEditingController();
  ChatServices chatServices = ChatServices();
  List<ChatMessage> messages = [];
  List<Map<String, String>> chatData = [
    {"role": "developer", "content": "You are a helpful assistant."},
  ];
  ChatUser user = ChatUser(
    id: '1',
    firstName: 'User',
    lastName: 'Name',
  );
  ChatUser openAiUser = ChatUser(
    id: '2',
    firstName: 'OpenAI',
    lastName: 'Assistant',
  );

  askChatGPT() async {
    if (messageController.text.isEmpty) return;
    messages.insert(
      0,
      ChatMessage(
        text: messageController.text,
        user: user,
        createdAt: DateTime.now(),
      ),
    );
    chatData.add({"role": "user", "content": messageController.text});
    setState(() {
      messageController.text = '';
    });
    result = await chatServices.askChatGPT(chatData);
    chatData.add({"role": "assistant", "content": result});
    messages.insert(
      0,
      ChatMessage(
        text: result,
        user: openAiUser,
        createdAt: DateTime.now(),
      ),
    );
    setState(() {
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  Padding buildBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: DashChat(
                currentUser: user,
                onSend: (ChatMessage m) {
                  askChatGPT();
                },
                readOnly: true,
                messages: messages,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.fromLTRB(8, 4, 8, 20),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 8,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Bạn muốn hỏi gì hôm nay?',
                        hintStyle: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
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
                ),
                IconButton(
                  onPressed: () {
                    askChatGPT();
                  },
                  icon: Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                  splashColor: Color(0xFF734f9a),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'Chat Screen',
        style: GoogleFonts.roboto(
          textStyle: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: true,
    );
  }
}
