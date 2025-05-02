import 'package:flutter/material.dart';
import 'package:tibebnet/screens/auth/login_screen.dart';
import 'dart:convert';
import 'package:tibebnet/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: '27858456749-offetu6aa8i67j82lkleporm4fgipasc.apps.googleusercontent.com', // Set your actual clientId here
  );
  
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _email;
  late final TextEditingController _confirmPassword;

  @override
  void initState() {
    _username = TextEditingController();
    _password = TextEditingController();
    _email = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _email.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1331),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildTextFields(),
              const SizedBox(height: 40),
              _buildSignUpButton(),
              const SizedBox(height: 30),
              _buildGoogleSignUpButton(),
              const SizedBox(height: 40),
              _buildLoginRedirect(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "TibebNet",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Please fill the input below here",
          style: TextStyle(color: Color(0x80FFFFFF), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        _customTextField(
          controller: _username,
          label: "Username",
          icon: Icons.person,
          obscureText: false,
        ),
        const SizedBox(height: 20),
        _customTextField(
          controller: _email,
          label: "Email",
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          obscureText: false,
        ),
        const SizedBox(height: 20),
        _customTextField(
          controller: _password,
          label: "Password",
          icon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 20),
        _customTextField(
          controller: _confirmPassword,
          label: "Confirm Password",
          icon: Icons.lock_outline,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0x80FFFFFF)),
        prefixIcon: Icon(icon, color: const Color(0x80FFFFFF)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0x80FFFFFF)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final authService = AuthService();

          final username = _username.text.trim();
          final email = _email.text.trim();
          final password = _password.text;
          final confirmPassword = _confirmPassword.text;

          if (password != confirmPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Passwords do not match",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
            return;
          }

          try {
            final response = await authService.registerUser(
              username: username,
              email: email,
              password: password,
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              final json = jsonDecode(response.body);
              final token = json['data']['token'];

              await const FlutterSecureStorage().write(
                key: 'auth_token',
                value: token,
              );
              print("Signup successful");

              // Navigate to login page with success message
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(
                    successMessage: "Sign Up Successful!",
                  ),
                ),
              );
            } else {
              final json = jsonDecode(response.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(json['message'] ?? 'Signup failed')),
              );
            }
          } catch (e) {
            print("Signup Error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Something went wrong")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(260, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          shadowColor: Colors.blueAccent.withOpacity(0.4),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignUpButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          try {
            // Start the sign-in process
            GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

            if (googleUser != null) {
              // Obtain the Google authentication token
              GoogleSignInAuthentication googleAuth =
                  await googleUser.authentication;

              // Call your backend to verify the Google token
              final authService = AuthService();
              final response = await authService.googleSignUp(
                idToken:googleAuth.idToken!,  // Send the ID token to your backend
              );

              if (response.statusCode == 200) {
                final json = jsonDecode(response.body);
                final token = json['data']['token'];

                // Store the token securely
                await const FlutterSecureStorage().write(
                  key: 'auth_token',
                  value: token,
                );

                print("Google Sign-Up successful");

                // Navigate to the login page with a success message
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(
                      successMessage: "Google Sign-Up Successful!",
                    ),
                  ),
                );
              } else {
                final json = jsonDecode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(json['message'] ?? 'Google Sign-Up failed'),
                  ),
                );
              }
            }
          } catch (e) {
            print("Google Sign-Up Error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Google sign-up failed. Please try again."),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(260, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          shadowColor: Colors.blueAccent.withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/google.png', height: 28, width: 28),
            const SizedBox(width: 12),
            const Text(
              'Sign Up with Google',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Login Redirect Button
  Widget _buildLoginRedirect(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an account?",
            style: TextStyle(color: Color(0x80FFFFFF), fontSize: 16),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
