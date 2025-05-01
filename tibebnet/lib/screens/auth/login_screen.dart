import 'package:flutter/material.dart';
import 'package:tibebnet/screens/auth/signup_screen.dart';
import 'dart:convert';
import 'package:tibebnet/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tibebnet/screens/Dashboard/dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  final String? successMessage;

  const LoginPage({super.key, this.successMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _password;
  late final TextEditingController _email;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _password = TextEditingController();
    _email = TextEditingController();

    // Use the success message passed from SignUpPage
    _successMessage = widget.successMessage;
  }

  @override
  void dispose() {
    _password.dispose();
    _email.dispose();
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
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              _buildTextFields(),
              const SizedBox(height: 40),
              _buildLoginButton(),
              const SizedBox(height: 30),
              _buildGoogleLoginButton(),
              const SizedBox(height: 40),
              _buildSignUpRedirect(context),
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
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Please sign in to continue",
          style: TextStyle(color: Color(0x80FFFFFF), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
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

  Widget _buildLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _handleLogin,
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
          'Login',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final authService = AuthService();
      // Corrected this line to use named arguments
      final response = await authService.loginUser(
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
      } else {
        final json = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  Widget _buildGoogleLoginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Handle Google Login (if implemented)
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
              'Sign in with Google',
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

  Widget _buildSignUpRedirect(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Doesn't have an account?",
            style: TextStyle(color: Color(0x80FFFFFF), fontSize: 16),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpPage()),
              );
            },
            child: const Text(
              "Sign Up",
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
