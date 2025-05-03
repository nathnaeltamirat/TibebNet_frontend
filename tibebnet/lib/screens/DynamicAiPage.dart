import 'package:flutter/material.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:tibebnet/screens/community/AllCommunityScreen.dart';
import 'package:tibebnet/screens/profile/ProfilePage.dart';
import 'package:tibebnet/screens/community_chat/CommunityChatPage.dart';
import 'package:tibebnet/screens/community/CreateCommunityPage.dart';
import 'package:tibebnet/screens/eventspage/EventsPage.dart';
import 'package:tibebnet/screens/post/PostPage.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  TextEditingController controller = TextEditingController();
  int _selectedIndex = 0;
  String userId = "";
  bool isTyping = false;
  bool showAnimation = false; // Flag to control showing animation

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostPage()),
      );
    } else if (_selectedIndex == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllCommunitiesScreen()),
      );
    } else if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventsPage()),
      );
    }
  }

  Future<void> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
    });
  }

  Future<void> fetchMessages() async {
    await fetchUserId();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse("http://localhost:3000/api/chat/history/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      setState(() {
        messages = json.decode(res.body);
      });
    }
  }

  Future<String> sendToAI(String userMessage) async {
    try {
      final nlpResponse = await http.post(
        Uri.parse(
          'https://api.nlpcloud.io/v1/gpu/finetuned-llama-3-70b/chatbot',
        ),
        headers: {
          'Authorization': 'Token af031c37e0741cab74763154e0c85d8038f5e0f4',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "input": userMessage,
          "context":
              "You are Tibeb, a thoughtful, kind, and helpful AI friend. You are part of a supportive mental health and career growth platform that uplifts marginalized voices. Users come to this app to share their stories, join safe communities, find mentorship, and feel seen. Your role is to have honest but respectful conversations, especially around emotional challenges, personal growth, and meaningful expression. "
              "You encourage users to reflect, grow, and feel proud of their contributions—especially when they share authentic posts. You can offer comfort, motivation, or practical guidance. Always reply supportively, even if you're delivering feedback. Never judge—listen first. You speak clearly, gently, and with care, like a close friend who wants the best for them. "
              "Every message you see is someone reaching out—sometimes bravely—so always acknowledge their courage, validate their emotions, and help them feel hopeful. If they shared a post or story, consider what emotions or effort might be behind it, and respond in a way that respects that vulnerability. "
              "Begin your response to each message with kindness and context awareness. You are here to support healing, expression, and empowerment. $userMessage",
          "history": [],
        }),
      );

      if (nlpResponse.statusCode != 200) throw Exception("error failed");

      final responseText = jsonDecode(nlpResponse.body)['response'];
      if (responseText == null || responseText.isEmpty) {
        setState(() {
          showAnimation = true; // Show animation if response is empty
        });
        throw Exception("Empty response from AI");
      }

      setState(() {
        showAnimation = false; // Hide animation when response is found
      });

      return responseText;
    } catch (e) {
      print("Error sending message to AI: $e");
      return "Tibeb couldn't respond right now.";
    }
  }

  Future<void> sendMessage(String userMessage) async {
    try {
      if (userMessage.trim().isEmpty) return;

      // Add user message immediately
      setState(() {
        messages.add({"sender": "user", "message": userMessage});
        isTyping = true;
      });

      controller.clear();

      // Get AI response
      String aiResponse = await sendToAI(userMessage);

      // Add AI response
      setState(() {
        messages.add({"sender": "ai", "message": aiResponse});
        isTyping = false;
      });

      // Save to backend
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.post(
        Uri.parse("http://localhost:3000/api/chat/send/$userId"),
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

      if (res.statusCode != 200) {
        print("Error saving message to the database: ${res.body}");
      }
    } catch (e) {
      print("Error sending message and saving it: $e");
      setState(() {
        isTyping = false;
      });
    }
  }

  Widget buildMessageBubble(message) {
    bool isUser = message['sender'] == 'user';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[600] : Colors.grey[800],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(isUser ? 12 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 12),
        ),
      ),
      child: Text(message['message'], style: TextStyle(color: Colors.white)),
    );
  }



  Widget typingIndicator() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Tibeb is typing", style: TextStyle(color: Colors.white70)),
          SizedBox(width: 6),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.blue),
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Tibeb",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage('assets/images/ai.png'),
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              reverse: true,
              children: [
                if (messages.isEmpty) // Show animation if there are no messages
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Lottie.asset(
                          'assets/animations/robot_ai.json',
                          width: 150,
                          height: 150,
                        ),
                      ),
                      Center(
                        child: Text(
                          "Hi, I'm Tibeb! 😊",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                if (isTyping) typingIndicator(),
                ...messages.reversed.map(buildMessageBubble).toList(),
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.black,
            child: Row(
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
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () => sendMessage(controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xFF2A2141),
        selectedItemColor: Color(0xFF007BFF),
        unselectedItemColor: Colors.blueGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 24,
              color: const Color.fromARGB(255, 128, 198, 255),
            ),
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
            icon: Icon(Icons.person, size: 24, color: Colors.blue),
            label: '',
          ),
        ],
      ),
    );
  }
}
