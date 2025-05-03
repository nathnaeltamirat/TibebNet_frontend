import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tibebnet/screens/eventspage/EventsPage.dart';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:tibebnet/screens/community/AllCommunityScreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tibebnet/screens/community_chat/CommunityChatPage.dart';
import 'package:tibebnet/screens/DynamicAiPage.dart';
import 'package:tibebnet/screens/profile/ProfilePage.dart';

class DashboardScreen extends StatefulWidget {
  final String? successMessage;

  const DashboardScreen({Key? key, this.successMessage}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;
  int _selectedIndex = 0;
  List<dynamic> _posts = [];
  String username = "Loading...";
  String profileImageUrl = "";
  bool isLoading = true;
  bool _isLoading = true;
  List<dynamic> _communities = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadUserData();
    _fetchCommunities();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      _currentPage = (_currentPage + 1) % 3;
      _controller.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
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

  Future<void> _fetchCommunities() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/communities/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _communities = data['communities'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load communities');
      }
    } catch (e) {
      print('Error fetching communities: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPosts() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/posts/all'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> posts = data['data'];

      final List<dynamic> enrichedPosts = await Future.wait(
        posts.map((post) async {
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
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final filteredPosts =
        _searchQuery.isEmpty
            ? _posts
            : _posts.where((post) {
              final content = post['content']?.toLowerCase() ?? '';
              final author =
                  post['authorDetails']?['username']?.toLowerCase() ?? '';
              return content.contains(_searchQuery) ||
                  author.contains(_searchQuery);
            }).toList();
    return Scaffold(
      backgroundColor: Color(0xFF1B113A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.successMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.successMessage!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _buildHeader(),
                    _buildSpacing(),
                    _buildSearchBar(),
                    _buildSpacing(),
                    _buildImageSlider(),
                    _buildSpacing(),
                    _buildCommunitySection(),
                    _buildSpacing(),
                    Text(
                      'POSTS AND EVENTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final post = filteredPosts[index];
                final authorDetails = post['authorDetails'] ?? {};
                final name = authorDetails['username'] ?? 'Unknown';
                final profileImage = authorDetails['profileImageUrl'] ?? '';
                final content = post['content'] ?? '';
                final image = post['image'] ?? '';
                final createdAt = post['createdAt'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildDynamicPostItem(
                    name,
                    profileImage,
                    content,
                    image,
                    createdAt,
                  ),
                );
              }, childCount: filteredPosts.length),
            ),
          ],
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
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(),
      ),
    );
  },
  child:  AnimatedSwitcher(
          duration: Duration(seconds: 3),
          child: Image.asset(
            'assets/images/ai.png', // Your AI icon
            key: ValueKey<int>(1), // Added a key to distinguish the widget for animation
            width: 55, // Icon size
            height: 55, // Icon size
          ),
        ),
  backgroundColor: Colors.blue, // Button background color
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
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2141),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : AssetImage('assets/images/person.jpg')
                            as ImageProvider,
                radius: 20,
              ),
              SizedBox(width: 8),
              Text(name, style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 5),
          Text(timeAgo, style: TextStyle(color: Colors.white54, fontSize: 12)),
          SizedBox(height: 10),
          Text(content, style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10),
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

  Widget _buildHeader() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : AssetImage('assets/images/person.jpg') as ImageProvider,
              radius: 30,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search posts/events',
          border: InputBorder.none,
          icon: Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Column(
      children: [
        Container(
          height: 180,
          child: PageView(
            controller: _controller,
            onPageChanged: (index) {
              _currentPage = index;
            },
            children: [
              _buildSliderItem('assets/images/c1.jpg'),
              _buildSliderItem('assets/images/c2.jpg'),
              _buildSliderItem('assets/images/c3.jpg'),
            ],
          ),
        ),
        SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _controller,
          count: 3,
          effect: WormEffect(
            dotColor: Colors.white24,
            activeDotColor: Colors.blue,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderItem(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
    );
  }

  Widget _buildSpacing() {
    return SizedBox(height: 20);
  }

  Widget _buildCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COMMUNITIES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllCommunitiesScreen(),
                  ),
                );
              },
              child: Text(
                'See all',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 60,
          child:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _communities.length,
                    itemBuilder: (context, index) {
                      final community = _communities[index];
                      return _buildCommunityChip(
                        community['name'],
                        community['id'],
                        community['image'],
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildCommunityChip(String label, int communityId, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityChatPage(communityId: communityId),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
