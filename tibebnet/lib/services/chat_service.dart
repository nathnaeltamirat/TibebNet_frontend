import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Change if needed

  // Fetch messages for the given communityId
Future<List<Map<String, dynamic>>> fetchMessages(int communityId) async {
  final response = await http.get(Uri.parse('$baseUrl/messages/$communityId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((message) {
      return {
        'id': message['_id'] ?? '',
        'senderUsername': message['senderId']?['username'] ?? 'Unknown User',
        'content': message['content'] ?? 'No Content',
        'createdAt': message['createdAt'] ?? 'Unknown',
        'updatedAt': message['updatedAt'] ?? 'Unknown',  // Add fallback for senderName
      };
    }).toList();
  } else {
    throw Exception('Failed to load messages');
  }
}




  // Send a message to the community
Future<void> sendMessage(int communityId, String content, String senderId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/messages/$communityId'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'senderId': senderId,   // Send only senderId and content as per backend requirements
      'content': content,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to send message');
  }
  else {
    print('Message sent successfully!');
  }
}

}
