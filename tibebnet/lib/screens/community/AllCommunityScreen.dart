import 'package:flutter/material.dart';
import 'package:tibebnet/services/community_service.dart';
import 'package:tibebnet/screens/community/community_card.dart';
import 'package:tibebnet/models/community_model.dart';
import 'package:tibebnet/screens/community/header.dart';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:tibebnet/screens/community/CreateCommunityPage.dart';
import 'package:tibebnet/screens/community_chat/CommunityChatPage.dart';

class AllCommunitiesScreen extends StatefulWidget {
  const AllCommunitiesScreen({Key? key}) : super(key: key);

  @override
  State<AllCommunitiesScreen> createState() => _AllCommunitiesScreenState();
}

class _AllCommunitiesScreenState extends State<AllCommunitiesScreen> {
  final CommunityService _communityService = CommunityService();
  late Future<List<Community>> _communityFuture;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _communityFuture = _communityService.fetchCommunities();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PostPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Explore Communities",
          style: TextStyle(color: Colors.blueAccent),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Community>>(
        future: _communityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No communities found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final communities = snapshot.data!;

          return Column(
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
                  child: const TextField(
                    decoration: InputDecoration(
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
                    itemCount: communities.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (context, index) {
                      final community = communities[index];
                      return CommunityCard(
                        community: community,
                        onTap: () {
                          try {
                            // Convert the ID to a number if it's a string, safely handle parsing errors
                            final communityId = community.id;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CommunityChatPage(
                                      communityId:
                                          communityId, // parsed as an integer
                                    ),
                              ),
                            );
                          } catch (e) {
                            print("Error parsing community ID: $e");
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCommunityPage(),
            ),
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
      ),
    );
  }
}
