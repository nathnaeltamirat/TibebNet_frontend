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
const Color primaryBlue = Color(0xFF3B82F6);
const Color backgroundColor = Color(0xFF1E293B);
const Color containerColor = Color(0xFF334155);

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final TextEditingController _post;
  String? _selectedOption;
  String? _imageUrl;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _post = TextEditingController();
  }

  @override
  void dispose() {
    _post.dispose();
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
    }
    else if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventsPage()),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/dyz3oqxod/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'flutter_unsigned'
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: pickedFile.name));

      final response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        setState(() => _imageUrl = data['secure_url']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed')));
      }
    }
  }

  Future<void> _submitPost() async {
    if (_post.text.isEmpty || _selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      final nlpResponse = await http.post(
        Uri.parse('https://api.nlpcloud.io/v1/gpu/finetuned-llama-3-70b/chatbot'),
        headers: {
          'Authorization': 'Token cb908883cb733a18791b34ec1a5354ac1a3bd67d',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "input": _post.text,
          "context":
              "You are an AI assistant named Patrick. Based on the post below, you will give a strict numeric rating from 0 to 100 depending on how helpful, meaningful, and socially supportive the content is. Only respond with a number. No explanations.\n\n"
              "Analyze the following social media post and assign it an educational/student relevance score between 0 and 100 based on these strict criteria:\n\n"
              "Educative Value (e.g., tutorials, study tips, career advice):\nHigh (70–100): Directly teaches a skill/concept (e.g., \"How to solve calculus problems\").\n"
              "Medium (30–69): Indirectly useful (e.g., \"Upcoming programming workshop\").\n"
              "Low (0–29): No educational value (e.g., \"My lunch today\").\n\n"
              "Event/Road Relevance (e.g., campus events, hackathons, road safety):\nHigh (70–100): Official student events, deadlines, or safety alerts.\n"
              "Medium (30–69): Informal meetups or tangential mentions.\n"
              "Low (0–29): Unrelated to events/roads.\n\n"
              "Student/Learner Importance:\nAutomatically 0 if the post is about personal gossip, ads, or irrelevant topics.",
          "history": []
        }),
      );

      if (nlpResponse.statusCode != 200) throw Exception("Scoring failed");

      final output = jsonDecode(nlpResponse.body)['response'];
      final points = int.tryParse(output.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      final postResponse = await http.post(
        Uri.parse('http://localhost:3000/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': _post.text,
          'image': _imageUrl,
          'points': points,
          'id': userId,
          'category': _selectedOption,
        }),
      );

      if (postResponse.statusCode == 201 || postResponse.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SuccessAnimationScreen(points: points)),
        );
      } else {
        throw Exception("Post failed: ${postResponse.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const GradientText(
          text: "TibebNet",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          gradient: LinearGradient(colors: [primaryBlue, Colors.blueAccent]),
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
            icon: Icon(Icons.add, size: 24, color: const Color.fromARGB(255, 128, 198, 255)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: "Write a Post"),
              const SizedBox(height: 16),
              PostContentSection(controller: _post),
              const SizedBox(height: 20),
              ImageUploadSection(imageUrl: _imageUrl, onPickImage: _pickImage),
              const SizedBox(height: 20),
              const SectionTitle(title: "Type of Post"),
              PostTypeSelector(
                selectedOption: _selectedOption,
                onChanged: (val) => setState(() => _selectedOption = val),
              ),
              const SizedBox(height: 20),
              SubmitButton(onPressed: _submitPost),
            ],
          ),
        ),
      ),
    );
  }
}

class PostContentSection extends StatelessWidget {
  final TextEditingController controller;
  const PostContentSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      label: "Post",
      hint: "Write your post here...",
      maxLines: 8,
    );
  }
}

class PostTypeSelector extends StatelessWidget {
  final String? selectedOption;
  final ValueChanged<String?> onChanged;
  const PostTypeSelector({required this.selectedOption, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ["Post", "Event"].map((option) {
        return Row(
          children: [
            Radio<String>(
              value: option,
              groupValue: selectedOption,
              onChanged: onChanged,
              activeColor: primaryBlue,
            ),
            Text(option, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 16),
          ],
        );
      }).toList(),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: const Text(
          "Share My Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const CustomInputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class ImageUploadSection extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onPickImage;

  const ImageUploadSection({required this.imageUrl, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Add Image"),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl!, fit: BoxFit.cover),
                  )
                : const Center(
                    child: Text("Tap to upload image", style: TextStyle(color: Colors.white54)),
                  ),
          ),
        ),
      ],
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class SuccessAnimationScreen extends StatelessWidget {
  final int points;

  const SuccessAnimationScreen({required this.points});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/success.json', width: 200),
            const SizedBox(height: 20),
            Text(
              "🎉 You've earned $points points!",
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              },
              child: const Text("Go to Dashboard", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
