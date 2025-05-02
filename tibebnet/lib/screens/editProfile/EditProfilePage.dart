import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:tibebnet/screens/profile/ProfilePage.dart';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:tibebnet/screens/community/AllCommunityScreen.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:tibebnet/screens/community_chat/CommunityChatPage.dart';
import 'package:tibebnet/screens/eventspage/EventsPage.dart';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  int points = 0;
  int postCount = 0;
  bool isLoading = true;
  bool isSaving = false;
  int _selectedIndex = 0;
  String userId = '';
  String profileImageUrl = '';
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';

    // Fetch user info
    final userResponse = await http.get(Uri.parse('http://localhost:3000/api/auth/$userId'));
    if (userResponse.statusCode == 200) {
      final data = jsonDecode(userResponse.body);
      final user = data['data']['user'];

      setState(() {
        _usernameController.text = user['username'];
        _aboutController.text = user['about'] ?? '';
        points = user['point'] ?? 0;
        profileImageUrl = user['profileImageUrl'] ?? '';
      });
    }

    // Fetch verified post count by this user
    final postResponse = await http.get(Uri.parse('http://localhost:3000/api/posts/all'));
    if (postResponse.statusCode == 200) {
      final posts = jsonDecode(postResponse.body)['data'];
      final verifiedPosts = posts.where((post) => post['author']['id'] == userId).toList();
      setState(() {
        postCount = verifiedPosts.length;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      isSaving = true;
    });

    final response = await http.patch(
      Uri.parse('http://localhost:3000/api/auth/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'about': _aboutController.text,
        'profileImageUrl': _imageUrl ?? profileImageUrl,
      }),
    );

    if (response.statusCode == 200) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        isSaving = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    } else {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile update failed')));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/dyz3oqxod/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'flutter_unsigned'
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: pickedFile.name));

      final response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        setState(() {
          _imageUrl = data['secure_url'];
          profileImageUrl = _imageUrl!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            currentIndex: _selectedIndex,
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
                icon: Icon(Icons.person, size: 24, color: Color.fromARGB(255, 128, 198, 255)),
                label: '',
              ),
            ],
          ),
          appBar: AppBar(
            title: const Text("Edit Profile", style: TextStyle(color: Colors.blue)),
            backgroundColor: const Color.fromARGB(255, 15, 14, 14),
            iconTheme: const IconThemeData(color: Colors.blue),
            elevation: 1,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage('assets/images/person.jpg') as ImageProvider,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: _pickImage,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Username",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _aboutController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "About",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _achievementBox("Points", points.toString(), Icons.star),
                          _achievementBox("Posts", postCount.toString(), Icons.article),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
        ),
        if (isSaving)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Lottie.asset('assets/animations/configured.json', width: 180, repeat: false),
            ),
          ),
      ],
    );
  }

  Widget _achievementBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
