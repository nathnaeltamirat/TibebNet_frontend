import 'dart:convert';
import 'package:flutter/material.dart';
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
          'updatedAt': message['updatedAt'] ?? 'Unknown',
        };
      }).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Send a message to the community
  Future<void> sendMessage(int communityId, String content, String senderId, {bool isFromAI = false}) async {
        final response = await http.post(
          Uri.parse('$baseUrl/messages/$communityId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'senderId': senderId,
            'content': content,
            'isFromAI': isFromAI,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send message');
        } else {
          print('Message sent successfully!');
        }
      }


  // Get AI response (via NLPCloud)
  Future<String> getAIResponse(int communityId, String userMessage) async {
    try {
      // Call NLPCloud for AI response
      final response = await http.post(
        Uri.parse('https://api.nlpcloud.io/v1/gpu/finetuned-llama-3-70b/chatbot'),
        headers: {
          'Authorization': 'Token af031c37e0741cab74763154e0c85d8038f5e0f4',  // Replace with your NLPCloud token
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "input": userMessage,
          "context": "You are Tibeb, a thoughtful, kind, and helpful AI friend. "
              "You are part of a supportive mental health and career growth platform that uplifts marginalized voices. "
              "Users come to this app to share their stories, join safe communities, find mentorship, and feel seen. "
              "Your role is to have honest but respectful conversations, especially around emotional challenges, personal growth, "
              "and meaningful expression. You encourage users to reflect, grow, and feel proud of their contributions—especially when "
              "they share authentic posts. You can offer comfort, motivation, or practical guidance. Always reply supportively, "
              "even if you're delivering feedback. Never judge—listen first. You speak clearly, gently, and with care, like a close friend "
              "who wants the best for them. Every message you see is someone reaching out—sometimes bravely—so always acknowledge their courage, "
              "validate their emotions, and help them feel hopeful. If they shared a post or story, consider what emotions or effort might be behind it, "
              "and respond in a way that respects that vulnerability. Begin your response to each message with kindness and context awareness. "
              "You are here to support healing, expression, and empowerment. $userMessage",
          "history": [],
        }),
      );

      // Check if NLPCloud request was successful
       if (response.statusCode != 200) throw Exception("error failed");

      final responseText = jsonDecode(response.body)['response'];
      if (responseText == null || responseText.isEmpty) {

        throw Exception("Empty response from AI");
      }

      print(responseText);

      return responseText;
    } catch (e) {
      print('Error in getAIResponse: $e');
      return "Sorry, there was an error connecting to Tibeb.";
    }
  }
}
