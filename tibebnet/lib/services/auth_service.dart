import "dart:convert";
import "package:google_sign_in/google_sign_in.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String baseUrl = "http://localhost:3000/api";

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
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

  // Corrected login method
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
        final token = jsonDecode(response.body)['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        print("Login successful. JWT saved securely.");
      } else {
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

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) return;
      final url = Uri.parse("$baseUrl/google-signin");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        print("Backend login successful. JWT: $token");
        // Store token securely (e.g., SharedPreferences)
      } else {
        throw Exception("Backend login failed: ${response.body}");
      }
    } catch (e) {
      // Use a logging framework instead of print
      print("Google sign-in error: $e");
    }
  }
}
