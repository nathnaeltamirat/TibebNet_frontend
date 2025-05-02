import 'package:flutter/material.dart';
import 'package:tibebnet/services/community_service.dart';
import 'package:tibebnet/screens/community/community_card.dart';
import 'package:tibebnet/models/community_model.dart';
import 'package:tibebnet/screens/community/header.dart';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:tibebnet/screens/community/CreateCommunityPage.dart';
import 'package:tibebnet/screens/community_chat/CommunityChatPage.dart';
import 'package:tibebnet/screens/profile/ProfilePage.dart';
import 'package:tibebnet/screens/eventspage/EventsPage.dart';

class AllCommunitiesScreen extends StatefulWidget {
  const AllCommunitiesScreen({Key? key}) : super(key: key);

  @override
  State<AllCommunitiesScreen> createState() => _AllCommunitiesScreenState();
}

class _AllCommunitiesScreenState extends State<AllCommunitiesScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _searchController = TextEditingController();
  List<Community> _allCommunities = [];
  List<Community> _filteredCommunities = [];
  int _selectedIndex = 1;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchCommunities() async {
    try {
      final communities = await _communityService.fetchCommunities();
      setState(() {
        _allCommunities = communities;
        _filteredCommunities = communities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommunities =
          _allCommunities
              .where(
                (community) => community.name.toLowerCase().contains(query),
              )
              .toList();
    });
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "All Communities",
          style: TextStyle(color: Colors.blueAccent),
        ),
        centerTitle: false,
        
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : _error.isNotEmpty
              ? Center(
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.white),
                ),
              )
              : Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: 'Search a community',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ExploreHeader(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _filteredCommunities.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, index) {
                          final community = _filteredCommunities[index];
                          return CommunityCard(
                            community: community,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CommunityChatPage(
                                        communityId: community.id,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCommunityPage()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(bottom: 3),
        color: const Color(0xFF2A2141),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
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
              icon: Icon(Icons.group, size: 24, color: Color(0xFF80C6FF)),
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
      ),
    );
  }
}
