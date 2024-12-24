import 'dart:convert';

import 'package:ai_chat_app/chat_services.dart';
import 'package:ai_chat_app/image_screen.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, Object>> chatData = [
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

  String result = '';
  bool isTts = false;
  TextEditingController messageController = TextEditingController();
  ChatServices chatServices = ChatServices();
  FlutterTts flutterTts = FlutterTts();
  List<ChatMessage> messages = [];

  convertImageToBase64() async {
    if (selectedImage != null) {
      final imageBytes = await selectedImage!.readAsBytes();
      return base64Encode(imageBytes);
    }
  }

  askChatGPT() async {
    if (messageController.text.isEmpty) return;
    if (isImageSelected) {
      isImageSelected = false;
      messages.insert(
        0,
        ChatMessage(
          text: messageController.text,
          user: user,
          medias: [
            ChatMedia(
              url: selectedImage!.path,
              fileName: 'image',
              type: MediaType.image,
            ),
          ],
          createdAt: DateTime.now(),
        ),
      );
      String imageBase64 = await convertImageToBase64();
      chatData.add({
        "role": "user",
        "content": [
          {
            "type": "image_url",
            "image_url": {"url": "data:image/png;base64,$imageBase64"}
          },
        ]
      });
      chatData.add({"role": "user", "content": messageController.text});
    } else {
      messages.insert(
        0,
        ChatMessage(
          text: messageController.text,
          user: user,
          createdAt: DateTime.now(),
        ),
      );
      chatData.add({"role": "user", "content": messageController.text});
    }
    setState(() {
      messageController.text = '';
      messages;
    });
    result = await chatServices.askChatGPT(chatData);
    if (isTts) {
      flutterTts.speak(result);
    }
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

  generateImages() async {
    if (messageController.text.isEmpty) return;
    String prompt = messageController.text;
    messages.insert(
      0,
      ChatMessage(
        text: messageController.text,
        user: user,
        createdAt: DateTime.now(),
      ),
    );
    setState(() {
      messageController.text = '';
      messages;
    });
    // List<String> result = await chatServices.generateImages(prompt);
    String result = await chatServices.generateImages(prompt);
    // List<ChatMedia> generatedImages = [];
    // result.forEach((url) {
    //   generatedImages.add(
    //     ChatMedia(
    //       url: url,
    //       fileName: 'image',
    //       type: MediaType.image,
    //     ),
    //   );
    // });
    messages.insert(
      0,
      ChatMessage(
        user: openAiUser,
        createdAt: DateTime.now(),
        // medias: generatedImages,
        medias: [
          ChatMedia(
            url: result,
            fileName: 'image',
            type: MediaType.image,
          ),
        ],
      ),
    );
    setState(() {
      result;
    });
  }

  ttsSetting() async {
    flutterTts.setLanguage('en-US');
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);
  }

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      messageController.text = result.recognizedWords;
    });
    if (result.finalResult) {
      if (messageController.text.startsWith('generate image')) {
        generateImages();
      } else {
        askChatGPT();
      }
    }
  }

  final ImagePicker picker = ImagePicker();
  bool isImageSelected = false;
  XFile? selectedImage;
  chooseImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      isImageSelected = true;
      selectedImage = image;
    }
  }

  captureImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      isImageSelected = true;
      selectedImage = image;
    }
  }

  @override
  void initState() {
    ttsSetting();
    _initSpeech();
    super.initState();
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
                messageOptions: MessageOptions(
                  onTapMedia: (item) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageScreen(url: item.url),
                      ),
                    );
                  },
                ),
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
                IconButton(
                  onPressed: () {
                    chooseImage();
                  },
                  icon: Icon(
                    Icons.attach_file_rounded,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Nhập "generate image" để tạo ảnh',
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
                    if (_speechEnabled) {
                      _startListening();
                    }
                  },
                  icon: Icon(
                    Icons.mic,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (messageController.text.startsWith('generate image')) {
                      generateImages();
                    } else {
                      askChatGPT();
                    }
                    flutterTts.stop();
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
      centerTitle: true,
      title: Text(
        'Chat Screen',
        style: GoogleFonts.roboto(
          textStyle: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {
          setState(() {
            messages.clear();
            chatData.clear();
            flutterTts.stop();
          });
        },
        icon: Icon(Icons.clear, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {
            captureImage();
          },
          icon: Icon(Icons.camera_alt, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            flutterTts.stop();
            if (isTts) {
              isTts = false;
            } else {
              isTts = true;
            }
            setState(() {
              isTts;
            });
          },
          icon: Icon(
            isTts ? Icons.record_voice_over : Icons.voice_over_off,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
