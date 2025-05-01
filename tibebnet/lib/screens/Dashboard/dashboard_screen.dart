import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tibebnet/screens/post/PostPage.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      _currentPage = (_currentPage + 1) % 3;
      _controller.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
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
    // Handle navigation based on selected index
    if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Postpage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildHeader(),
                    _buildSpacing(),
                    _buildSearchBar(),
                    _buildSpacing(),
                    _buildImageSlider(),
                    _buildSpacing(),
                    _buildCommunitySection(),
                    _buildSpacing(),
                    Text(
                      'POSTS',
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildPostItem(),
                );
              }, childCount: 5),
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/profile.png'),
          radius: 30,
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello!', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text(
              'John William',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Search here',
              style: TextStyle(color: Colors.white54, fontSize: 12),
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
        decoration: InputDecoration(
          hintText: 'Search learning paths',
          border: InputBorder.none,
          icon: Icon(Icons.search),
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
            activeDotColor: Colors.blueAccent,
            dotHeight: 10,
            dotWidth: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderItem(String imageUrl) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Community',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Add navigation logic here if needed
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCommunityItem('GDG', 'Community', 'assets/images/google.png'),
            _buildCommunityItem(
              'Amazon',
              'Community',
              'assets/images/google.png',
            ),
            _buildCommunityItem(
              'Meta',
              'Community',
              'assets/images/google.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityItem(String title, String subtitle, String imagePath) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 30, width: 30),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(subtitle, style: TextStyle(color: Colors.black54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPostItem() {
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
                backgroundImage: AssetImage('assets/images/person.png'),
                radius: 20,
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mikiyas Tamirat',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Yesterday',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Most people prefer starting with Python since it is easy to implement and helps in understanding logic easily. '
            'However, doing this can limit your understanding of core software engineering concepts. In my opinion, if you want to become great '
            'at software engineering, try to start with low-level languages or those that are closer to the hardware.',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 10),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/c.png', height: 50, width: 50),
                  SizedBox(width: 8),
                  Text(
                    'vs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Image.asset('assets/python.png', height: 50, width: 50),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildTag('python'),
              SizedBox(width: 8),
              _buildTag('beginner'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(tag, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildSpacing([double height = 20]) {
    return SizedBox(height: height);
  }
}
