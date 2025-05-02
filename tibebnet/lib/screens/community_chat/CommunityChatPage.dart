import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tibebnet/services/chat_service.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:tibebnet/services/auth_service.dart';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:timeago/timeago.dart' as timeago;
class CommunityChatPage extends StatefulWidget {
  final int communityId;

  const CommunityChatPage({Key? key, required this.communityId})
    : super(key: key);

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}
class _CommunityChatPageState extends State<CommunityChatPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  Timer? _refreshTimer;
  int? _selectedIndex;
  List<dynamic> messages = [];
  Map<String, dynamic>? communityData;
  String? userId;  // Declare userId here

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

Future<void> _initializeUserId() async {
  try {
    // Simulating async call to get user ID
    var userId = await AuthService().getUserId();
    setState(() {
      // Update the state here
      this.userId = userId;
    });
  } catch (e) {
    print("Error initializing user ID: $e");
  }
}

  @override
  void initState() {
    super.initState();
    _fetchCommunityData();
    _fetchMessages();
    _initializeUserId();  // Initialize userId on start
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PostPage()),
      );
    }
  }

  Future<void> _fetchCommunityData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/api/communities/${widget.communityId}',
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() => communityData = data['community']);
      } else {
        print('Failed to load community data');
      }
    } catch (e) {
      print('Error fetching community data: $e');
    }
  }

  bool _isFetchingMessages = false;

  Future<void> _fetchMessages() async {
    if (_isFetchingMessages) return; // Prevent overlapping fetches
    _isFetchingMessages = true;

    try {
      final fetchedMessages = await apiService.fetchMessages(
        widget.communityId,
      );
      setState(
        () => messages = fetchedMessages,
      ); // Update the UI with the fetched messages
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      _isFetchingMessages = false;
    }
  }
  // Add a check to send message only if userId is available
  void _sendMessage(String content) async {
    if (userId == null) {
      print("User ID is not available.");
      return;  // Do not send message if user ID is not available
    }
    print("Sending message: $content");
    print("User ID: $userId");
    print("Community ID: ${widget.communityId}");

    try {
      await apiService.sendMessage(widget.communityId, content, userId!);
      print("Message sent successfully.");
      _controller.clear();
      await _fetchMessages();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // App header
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    "TibebNet",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Community info header
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
                    child:
                        communityData != null && communityData!['image'] != null
                            ? Image.network(
                              communityData!['image'],
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                            )
                            : Container(
                              width: 45,
                              height: 45,
                              color: Colors.grey[800],
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      communityData != null
                          ? communityData!['name']
                          : 'Loading...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child:
                  messages.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey,
                              size: 40,
                            ),
                            Text(
                              "No messages yet",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return chatBubble(message);
                        },
                      ),
            ),

            // Input field
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
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                    onPressed: userId == null
                        ? null  // Disable button if userId is not available
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
      // Bottom Nav Bar
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF2A2141),
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: Colors.blueGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24, color: Colors.blue),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group,
              size: 24,
              color: Color.fromARGB(255, 128, 198, 255),
            ),
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


  Widget chatBubble(dynamic message) {
    DateTime? createdAt = DateTime.tryParse(message['createdAt']);
    String formattedTime =
        createdAt != null ? timeago.format(createdAt) : 'Unknown Time';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              "http://localhost:3000/api/users/${message['senderId']}/image",
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(Icons.account_circle, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF32425C),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['senderUsername'] ?? 'Unknown User', // Handle null
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message['content'] ?? 'No Content', // Handle null
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

