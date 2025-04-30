import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernamecontroller = TextEditingController(text: "nathnael");
  final TextEditingController _aboutcontroller = TextEditingController(text: "simple but significant nathnarel tamirat from addis");
  String? _selectedOption;
  String? _imageUrl;
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    
    ;
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/dyz3oqxod/image/upload',
      );
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['upload_preset'] = 'flutter_unsigned'
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                bytes,
                filename: pickedFile.name,
              ),
            );

      final response = await request.send();

      if (response.statusCode == 200) {
        final respData = jsonDecode(await response.stream.bytesToString());
        final imageUrl = respData['secure_url'];

        setState(() {
          _imageUrl = imageUrl;
        });
      } else {
        print('Failed to upload: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: Color(0xFF0CF2E0),
        unselectedItemColor: Color(0x800CF2E0),
        backgroundColor: Color.fromARGB(128, 110, 108, 108),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8.0), // Moves the icon down
              child: Icon(Icons.home, size: 30), // Increases icon size
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.people, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.add, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.calendar_today, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.person, size: 30),
            ),
            label: '',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GradientText(
                    text: "TibebNet",
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0CF2E0), Color(0xFF078C82)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ClipOval(
                          child:
                              _imageUrl == null
                                  ? Image.asset(
                                    "assets/images/person.jpg",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.network(_imageUrl!),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _pickImage();
                            // Add functionality to change the image here
                            print("Edit icon pressed");
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width:20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Change Name",
                          style:TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color:Colors.white,
                          )
                        ),
                        SizedBox(
                          height:5,
                        ),
                       TextField(
                          controller: _usernamecontroller,
                          style: TextStyle(color: Colors.white), // This sets the input text color
                          decoration: InputDecoration(
                            fillColor: const Color.fromARGB(255, 50, 130, 72),
                            filled: true, // Applies the background fill color
                            hintText: "Enter your name",
                            hintStyle: TextStyle(color: Colors.white), // Hint text color
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white), // Optional: white border when focused
                            ),
                          ),
                        ),
                      const SizedBox(height:20),
                       Text(
                          "Change about",
                          style:TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color:Colors.white,
                          )
                        ),
                        SizedBox(
                          height:5,
                        ),
                       TextField(
                          maxLines: 4,
                          controller: _aboutcontroller,
                          style: TextStyle(color: Colors.white), // This sets the input text color
                          decoration: InputDecoration(
                            fillColor: const Color.fromARGB(255, 50, 130, 72),
                            filled: true, // Applies the background fill color
                            hintText: "Enter your name",
                            hintStyle: TextStyle(color: Colors.white), // Hint text color
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white), // Optional: white border when focused
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height:10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[ ElevatedButton(
                  onPressed: () {
                    // Add functionality to handle form submission
                    print("Submit button pressed");
                    print("Username: ${_usernamecontroller.text}");
                    print("About: ${_aboutcontroller.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 52, 202, 109), // Button background color
                    foregroundColor: Colors.black, // Button text color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Achievements",
                  style:TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color:Colors.white,
                  )
                ),
              Container(
      color: Color(0xFF1D1233), // Background color
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left Side Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // width: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2E1E49),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                 
                  children: [
                    Icon(Icons.emoji_events, color: Color(0xFF00E5D2)),
                    const SizedBox(width: 8),
                    Container(
                      width:148,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '1250',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            'Points earned',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(minWidth: 120, maxWidth: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2E1E49),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF00E5D2)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '45',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          'Posts Verified',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Right Side Image
          Expanded(
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/achievement_banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    )

            ],
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    Key? key,
    required this.text,
    required this.gradient,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback:
          (bounds) => gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}
