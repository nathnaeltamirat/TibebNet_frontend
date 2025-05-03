import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tibebnet/services/chat_service.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:tibebnet/services/auth_service.dart';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tibebnet/screens/profile/ProfilePage.dart';
import 'package:tibebnet/screens/community/AllCommunityScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:tibebnet/screens/community_chat/CommunityChatPage.dart';

class CommunityChatPage extends StatefulWidget {
  final int communityId;

  const CommunityChatPage({Key? key, required this.communityId}) : super(key: key);

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  int? _selectedIndex;
  List<dynamic> messages = [];
  Map<String, dynamic> userProfiles = {};
  Map<String, dynamic>? communityData;
  String? userId;

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else if (index == 1 || index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AllCommunitiesScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PostPage()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
    }
  }

  Future<Map<String, dynamic>> _getUserProfile(String userId) async {


    if (userProfiles.containsKey(userId)) return userProfiles[userId]!;

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/auth/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['data']['user'];
        userProfiles[userId] = user;
        return user;
      }
    } catch (e) {
      print('Error fetching user $userId: $e');
    }
    return {"username": "Unknown", "profileImageUrl": ""};
  }

  Future<void> _initializeUserId() async {
    try {
      final id = await AuthService().getUserId();
      setState(() => userId = id);
    } catch (e) {
      print("Error getting user ID: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    _fetchCommunityData();
    _fetchMessages();
  }

  Future<void> _fetchCommunityData() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/communities/${widget.communityId}'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => communityData = data['community']);
      }
    } catch (e) {
      print('Error fetching community data: $e');
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:3000/api/messages/${widget.communityId}'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => messages = List.from(data));
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

// Add this to the class body (_CommunityChatPageState)
void _sendMessage(String content) async {
  if (userId == null || content.trim().isEmpty) return;

  try {
    // 1. Send the user's message
    await apiService.sendMessage(widget.communityId, content, userId!);
    _controller.clear();
    await _fetchMessages();

    // 2. Check for AI trigger
    if (content.toLowerCase().contains("tibeb")) {
      final aiResponse = await apiService.getAIResponse(widget.communityId, content);
      await apiService.sendMessage(widget.communityId, aiResponse, '681663c722fe544dbe03c943', isFromAI: true);
      await _fetchMessages();
    }
  } catch (e) {
    print('Error sending or receiving message: $e');
  }
}



  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final sender = message['senderId'] is String ? {'id': message['senderId']} : message['senderId'];
    final senderId = sender['id'];
    final content = message['content'] ?? '';
    final createdAt = DateTime.tryParse(message['createdAt']) ?? DateTime.now();  

    return FutureBuilder(
      future: _getUserProfile(senderId),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? {};
        final profileImage = profile['profileImageUrl'];
        final senderName = profile['username'] ?? "Unknown";

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profileImage != null && profileImage.startsWith('assets/')
                ? AssetImage(profileImage) as ImageProvider
                : (profileImage != null && profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : AssetImage('assets/images/person.jpg') as ImageProvider),
          ),
          title: Text(senderName, style: const TextStyle(color: Colors.white)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content, style: const TextStyle(color: Colors.white70)),
              Text(timeago.format(createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    "TibebNet",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: communityData != null && communityData!['image'] != null
                        ? Image.network(
                            communityData!['image'],
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported, color: Colors.grey),
                          )
                        : Container(width: 45, height: 45, color: Colors.grey[800]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      communityData != null ? communityData!['name'] : 'Loading...',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 200, child: Lottie.asset('assets/animations/no_messages.json')),
                          const SizedBox(height: 16),
                          const Text("No messages yet!", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text("Be the first to say something 🎉",
                              style: TextStyle(color: Colors.blueAccent, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: const Color(0xFF2A2141),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF32425C),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent, size: 28),
                    onPressed: userId == null
                        ? null
                        : () {
                            final text = _controller.text;
                            if (text.isNotEmpty) _sendMessage(text);
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF2A2141),
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: Colors.blueGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 24, color: Colors.blue), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.group, size: 24, color: Color.fromARGB(255, 128, 198, 255)), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add, size: 24, color: Colors.blue), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assignment, size: 24, color: Colors.blue), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 24, color: Colors.blue), label: ''),
        ],
      ),
    );
  }
}
