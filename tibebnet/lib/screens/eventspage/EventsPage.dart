import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:convert';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:tibebnet/screens/community/AllCommunityScreen.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:tibebnet/screens/profile/ProfilePage.dart';
import 'package:tibebnet/screens/community_chat/CommunityChatPage.dart';
class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  int _selectedIndex = 0;
  List<dynamic> _posts = [];
  List<dynamic> _filteredPosts = [];
  String username = "Loading...";
  String profileImageUrl = "";
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadUserData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPosts = _posts.where((post) {
        final content = post['content']?.toLowerCase() ?? '';
        return content.contains(query);
      }).toList();
    });
  }

  Future<void> _loadPosts() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/posts/all'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> posts = data['data'];

      List<dynamic> eventPosts =
          posts.where((post) => post['category'].toString().toLowerCase() == 'event').toList();

      final List<dynamic> enrichedPosts = await Future.wait(
        eventPosts.map((post) async {
          final authorId = post['author']['id'];
          final userRes = await http.get(
            Uri.parse('http://localhost:3000/api/auth/$authorId'),
          );

          if (userRes.statusCode == 200) {
            final userData = jsonDecode(userRes.body)['data']['user'];
            post['authorDetails'] = {
              'username': userData['username'],
              'profileImageUrl': userData['profileImageUrl'] ?? '',
            };
          } else {
            post['authorDetails'] = {
              'username': 'Unknown',
              'profileImageUrl': '',
            };
          }
          return post;
        }),
      );

      setState(() {
        _posts = enrichedPosts;
        _filteredPosts = enrichedPosts;
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/auth/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['data']['user'];

        setState(() {
          username = user['username'] ?? 'Unknown User';
          profileImageUrl = user['profileImageUrl'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          username = 'Error loading user';
          isLoading = false;
        });
      }
    }
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
    }
    else if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventsPage()),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text("Events", style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
              color: Colors.blue,
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
            icon: Icon(Icons.assignment, size: 24, color: const Color.fromARGB(255, 128, 198, 255)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24, color: Colors.blue),
            label: '',
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              for (var post in _filteredPosts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildDynamicPostItem(
                    post['authorDetails']?['username'] ?? 'Unknown',
                    post['authorDetails']?['profileImageUrl'] ?? '',
                    post['content'] ?? '',
                    post['image'] ?? '',
                    post['createdAt'] ?? '',
                  ),
                ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildDynamicPostItem(
    String name,
    String profileImage,
    String content,
    String imageUrl,
    String createdAt,
  ) {
    DateTime postDate = DateTime.tryParse(createdAt) ?? DateTime.now();
    String timeAgo = timeago.format(postDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2141),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : const AssetImage('assets/images/person.jpg') as ImageProvider,
                radius: 20,
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 5),
          Text(timeAgo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
