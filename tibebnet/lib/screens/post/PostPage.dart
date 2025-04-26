import "package:flutter/material.dart";
import 'package:tibebnet/screens/auth/login_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Postpage extends StatefulWidget {
  const Postpage({super.key});

  @override
  State<Postpage> createState() => _PostpageState();
}

class _PostpageState extends State<Postpage> {
  late final TextEditingController _title;
  late final TextEditingController _post;
  late final TextEditingController _imageController;
  String? _selectedOption;
  String? _imageUrl;

Future<void> _pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);;
  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes();

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/dyz3oqxod/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'flutter_unsigned'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: pickedFile.name,
      ));

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
  void initState() {
    _title = TextEditingController();
    _post = TextEditingController();
    _imageController = TextEditingController();
    _selectedOption = null;

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _post.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
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
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0x9074707E),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Write a Post",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Title",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: _title,
                        maxLines: 1, // Allows for a larger text field
                        decoration: InputDecoration(
                          hintText: "Write your title here...",
                          hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0x9074707E),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0x9074707E),
                            ),
                          ),

                          filled: true,
                          fillColor: const Color(
                            0x9074707E,
                          ), // Background color
                        ),
                      ),
                      const SizedBox(height: 13),
                      Text(
                        "Post",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: _post,
                        maxLines: 8, // Allows for a larger text field
                        decoration: InputDecoration(
                          hintText: "Write your post here...",
                          hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0x9074707E),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0x9074707E),
                            ),
                          ),

                          filled: true,
                          fillColor: const Color(
                            0x9074707E,
                          ), // Background color
                        ),
                      ),
                      const SizedBox(height: 20),
                      DottedBorder(
                        color: Colors.white,
                        strokeWidth: 1,
                        dashPattern: [6, 3],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child:
                                _imageUrl  == null
                                    ? Column(
                                      children: [
                                        const Icon(
                                          Icons.image_rounded,
                                          color: Color(0xFF15EBFF),
                                          size: 80,
                                        ),
                                        const Text(
                                          "Browse an Image",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Text(
                                          "Formats: jpg, png, jpeg",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        ElevatedButton(
                                          onPressed: _pickImage,
                                          child: const Text(
                                            "Browse Files",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF0CF2E0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Column(
                                      children: [
                                        Image.network(_imageUrl!),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: _pickImage,
                                          child: const Text(
                                            "Change Image",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        "Type of Post",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 7),
                      // radio button for post and event
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Post',
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                            fillColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF0CF2E0),
                            ),
                            activeColor: const Color(0xFF0CF2E0),
                          ),
                          const Text(
                            'Post',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'Event',
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                            fillColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF0CF2E0),
                            ),
                            activeColor: const Color(0xFF0CF2E0),
                          ),
                          const Text(
                            'Event',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          "Share My Post",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0CF2E0),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
