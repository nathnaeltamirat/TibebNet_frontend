import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Import shared_preferences
import 'package:http/http.dart' as http;

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String baseUrl = "http://localhost:3000/api";

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  Future<http.Response> registerUser({
    required String username,
    required String email,
    required String password,
  }) {
    final url = Uri.parse("$baseUrl/auth/signup");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );
  }
Future<void> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await loginUser(
      email: email,
      password: password,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final token = data['token'];
      final userId = data['user']?['id'];

      if (token != null && userId != null) {
        // Save token and userId in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_id', userId.toString());
        print("Token: $token");
        print("User ID: $userId");
        print("Login successful. JWT and user ID saved.");
      } else {
        throw Exception("Missing token or user ID in response");
      }
    } else if (response.statusCode == 401) {
      print("Login failed: ${response.body}");
      throw Exception("Invalid login credentials");
    }
  } catch (e) {
    print("Login error: $e");
    throw Exception("Login failed");
  }
}


  Future<http.Response> loginUser({
    required String email,
    required String password,
  }) {
    final url = Uri.parse("$baseUrl/auth/login");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  // Future<void> signInWithGoogle() async {
  //   try {
  //     final googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return;
  //     final googleAuth = await googleUser.authentication;
  //     final idToken = googleAuth.idToken;
  //     if (idToken == null) return;
  //     final url = Uri.parse("$baseUrl/google-signin");
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"idToken": idToken}),
  //     );
  //     if (response.statusCode == 200) {
  //       final body = jsonDecode(response.body);
  //       final token = body['token'];

  //       // Save token in SharedPreferences
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('auth_token', token);
  //       print("Google sign-in successful. JWT: $token");
  //     } else {
  //       throw Exception("Backend login failed: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Google sign-in error: $e");
  //   }
  // }

  // Get user ID from SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
