import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tibebnet/models/community_model.dart';

class CommunityService {
  final String _baseUrl = 'http://localhost:3000/api/communities';
  final String _uploadPreset = 'flutter_unsigned';
  final String _cloudName = 'dyz3oqxod';
  final String _uploadUrl = 'https://api.cloudinary.com/v1_1/dyz3oqxod/image/upload';

  // ✅ Fixed image upload function
  Future<String?> pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: pickedFile.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            pickedFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        return data['secure_url'];
      } else {
        print('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

    // Create a community
  Future<bool> createCommunity(String name, String description, String? imageUrl, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 👈 Add the token here
        },
        body: json.encode({
          'name': name,
          'description': description,
          'image': imageUrl ?? '',
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create community: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      throw Exception('Error creating community: $e');
    }
  }

  // Only for mobile use — you can remove if unused
  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/communities/'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['communities'];
      return data.map((json) => Community.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load communities');
    }
  
}
}
