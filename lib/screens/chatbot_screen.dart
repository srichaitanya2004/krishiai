import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, dynamic>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  static const String apiKey = "AIzaSyBdMuRVO-CE9iuX6sCVUEkInlf4JwumQVY";

  Future<String> _getAIResponse() async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$apiKey",
    );

    // Prepare conversation history
    List<Map<String, dynamic>> contents = [];

    // System instruction
    contents.add({
      "role": "user",
      "parts": [
        {
          "text":
              "You are an agricultural expert helping Indian farmers. Give practical, step-by-step advice.",
        },
      ],
    });

    // Add previous conversation
    for (var message in _chatMessages) {
      contents.add({
        "role": message['isUser'] ? "user" : "model",
        "parts": [
          {"text": message['text']},
        ],
      });
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"contents": contents}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      return "Server Error: ${response.statusCode}";
    }
  }

  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty || _isLoading) return;

    final userText = _chatController.text.trim();

    setState(() {
      _chatMessages.add({'text': userText, 'isUser': true});
      _isLoading = true;
    });

    _chatController.clear();
    _scrollToBottom();

    try {
      final aiResponse = await _getAIResponse();

      setState(() {
        _chatMessages.add({'text': aiResponse, 'isUser': false});
      });
    } catch (e) {
      setState(() {
        _chatMessages.add({
          'text': "Something went wrong. Please try again.",
          'isUser': false,
        });
      });
    }

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrishiAI Assistant"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];

                return Align(
                  alignment: message['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message['isUser']
                          ? Colors.green[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text'],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.green),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: "Ask about farming...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
