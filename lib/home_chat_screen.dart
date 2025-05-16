import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:new_solarc/widgets/animated_send_button.dart';

class HomeChatScreen extends StatefulWidget {
  final String? diseaseLabel;
  const HomeChatScreen({super.key, this.diseaseLabel});

  @override
  _HomeChatScreenState createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isTtsEnabled = true;

  final List<Widget> _chatWidgets = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.5);

    _chatWidgets.add(ChatBubble(
      message: "🌞 Hi! I’m SolarC, your AI skin assistant.\nLet me know how I can help you today!",
      isUser: false,
      profileImage: 'assets/images/chatbot_image.jpg',
    ));

  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _controller.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _chatWidgets.add(ChatBubble(message: userText, isUser: true));
      _controller.clear();
    });

    final url = Uri.parse('http://192.168.14.203:3000/chat/rag');

    final history = _chatWidgets
        .whereType<ChatBubble>()
        .map((w) => {
      "role": w.isUser ? "user" : "assistant",
      "content": w.message
    })
        .toList();

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"history": history}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = data['response'];

        setState(() {
          _chatWidgets.add(ChatBubble(
              message: aiMessage,
              isUser: false,
              profileImage: 'assets/images/chatbot_image.jpg'));
        });

        if (_isTtsEnabled) {
          await _tts.speak(aiMessage);
        }
      } else {
        setState(() {
          _chatWidgets.add(ChatBubble(
              message: "⚠️ Error from server.",
              isUser: false,
              profileImage: 'assets/images/chatbot_image.jpg'));
        });
      }
    } catch (e) {
      setState(() {
        _chatWidgets.add(ChatBubble(
            message: "⚠️ Failed to connect.",
            isUser: false,
            profileImage: 'assets/images/chatbot_image.jpg'));
      });
    }

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "SolarC ☀️",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.grey[800],
            ),
            onPressed: () async {
              setState(() {
                _isTtsEnabled = !_isTtsEnabled;
              });
              if (!_isTtsEnabled) {
                await _tts.stop();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _chatWidgets.length,
              itemBuilder: (context, index) => _chatWidgets[index],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration.collapsed(hintText: "Enter message"),
                  ),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: _listen,
                ),
                AnimatedSendButton(
                  onPressed: _sendMessage,
                  controller: _controller,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? profileImage;

  const ChatBubble({
    required this.message,
    required this.isUser,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && profileImage != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(profileImage!),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.teal[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: MarkdownBody(
                data: message,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 16),
                  strong: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
