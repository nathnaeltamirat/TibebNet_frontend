import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  TextEditingController controller = TextEditingController();
  int _selectedIndex = 0;
  String userId = ""; // This will store the user_id

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  // Fetching the user_id from SharedPreferences
  Future<void> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? ''; // Retrieve user_id
    });
  }

  Future<void> fetchMessages() async {
    await fetchUserId(); // Ensure we have userId before fetching
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse(
        "http://localhost:3000/api/chat/history/$userId",
      ), // Pass user_id to the URL
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      setState(() {
        messages = json.decode(res.body);
      });
    }
  }

  // Function to send message to AI
  Future<String> sendToAI(String userMessage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      final nlpResponse = await http.post(
        Uri.parse(
          'https://api.nlpcloud.io/v1/gpu/finetuned-llama-3-70b/chatbot',
        ),
        headers: {
          'Authorization': 'Token cb908883cb733a18791b34ec1a5354ac1a3bd67d',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "input": userMessage,
          "context":
              "ou are Tibeb, a thoughtful, kind, and helpful AI friend. You have honest but respectful conversations. " +
              "Always reply supportively, offering encouragement, comfort, or helpful ideas. " +
              "If someone shares something personal or emotional, respond with empathy and care. " +
              "Speak clearly and kindly, like a friend who listens without judgment.\n\n ${userMessage}",
          "history": [],
        }),
      );

      if (nlpResponse.statusCode != 200) {
        throw Exception("Scoring failed");
      }

      final responseText = jsonDecode(nlpResponse.body)['response'];
      if (responseText == null || responseText.isEmpty) {
        throw Exception("Empty response from AI");
      }
      return responseText;
    } catch (e) {
      print("Error sending message to AI: $e");
      return "AI could not respond.";
    }
  }

  // Function to send a message and save both user message and AI response to the database
  Future<void> sendMessage(String userMessage) async {
    try {
      // Send the message to the AI and get the response
      String aiResponse = await sendToAI(userMessage);

      // Save both user message and AI response to the database
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.post(
        Uri.parse(
          "http://localhost:3000/api/chat/send/$userId",
        ), // Pass user_id to the URL
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "messages": [
            {"sender": "user", "message": userMessage},
            {"sender": "ai", "message": aiResponse},
          ],
        }),
      );

      if (res.statusCode == 200) {
        print("Message and AI response saved successfully.");
        controller.clear();
        fetchMessages(); // Refresh messages
      } else {
        print("Error saving message to the database: ${res.body}");
      }
    } catch (e) {
      print(
        "Error sending message to the AI and saving it to the database: $e",
      );
    }
  }

  Widget buildMessageBubble(message) {
    bool isUser = message['sender'] == 'user';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[600] : Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(message['message'], style: TextStyle(color: Colors.white)),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Talk to Tibeb"),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              reverse: true,
              children: messages.reversed.map(buildMessageBubble).toList(),
            ),
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Say something...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.blue),
                onPressed: () => sendMessage(controller.text),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF2A2141),
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24, color: Colors.blue),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, size: 24, color: Colors.blue),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 24, color: Colors.blue),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, size: 24, color: Colors.blue),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 24,
              color: Color.fromARGB(255, 128, 198, 255),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
