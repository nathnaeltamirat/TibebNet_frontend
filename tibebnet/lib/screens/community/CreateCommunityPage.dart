import 'package:flutter/material.dart';
import 'package:tibebnet/screens/post/PostPage.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';
import 'package:tibebnet/services/community_service.dart';
import 'package:tibebnet/screens/community/AllCommunityScreen.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({Key? key}) : super(key: key);

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrl;
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MTM2ODVhMzQxZDdkMzRmMGRhNmMzNSIsImlhdCI6MTc0NjE1MjYxMiwiZXhwIjoxNzQ2MTU2MjEyfQ.sv7UfcqO2Ys21YK1oMCPZukUefz5rMNAj7Kq0qdMXb4';
  bool _isCommunityCreated = false;
  String successMessage = ''; // Store success message
  final String _successImageUrl = "https://your_success_image_url_here";
  int _selectedIndex = 0;

  final CommunityService _communityService = CommunityService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }else if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllCommunitiesScreen()),
      );
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostPage()),
      );
    } 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final url = await _communityService.pickAndUploadImage();
    if (url != null) {
      setState(() {
        _imageUrl = url;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image upload failed')));
    }
  }

  Future<void> _createCommunity() async {
    final isSuccess = await _communityService.createCommunity(
      _nameController.text.trim(),
      _descriptionController.text.trim(),
      _imageUrl,
      token,
    );

    if (isSuccess) {
      setState(() {
        _isCommunityCreated = true;
        successMessage =
            'Community successfully created!'; // Set success message
        _nameController.clear(); // Clear the name input
        _descriptionController.clear(); // Clear the description input
        _imageUrl = null; // Clear the image
      });

      // Optional: Reset success message after a short duration (e.g., 2 seconds)
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isCommunityCreated = false;
          successMessage = ''; // Reset success message
        });
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error creating community')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'TibebNet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007BFF),
              ),
            ),
            Spacer(),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show success message after community is created
            if (_isCommunityCreated)
              Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ), // Success icon
                  Text(
                    successMessage, // Display success message
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Text(
              "Create Community",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            CustomInputField(
              controller: _nameController,
              label: "Community Name",
              hint: "Enter name",
            ),
            const SizedBox(height: 16),
            CustomInputField(
              controller: _descriptionController,
              label: "Description",
              hint: "Write a description",
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ImageUploadSection(imageUrl: _imageUrl, onPickImage: _pickImage),
            const SizedBox(height: 24),
            // Always show the "Create Community" button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _createCommunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Create Community",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
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
            icon: Icon(Icons.person, size: 24, color: Colors.blue),
            label: '',
          ),
        ],
      ),
    );
  }
}
