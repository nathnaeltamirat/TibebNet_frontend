import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AISafetyInfoScreen extends StatefulWidget {
  const AISafetyInfoScreen({super.key});

  @override
  State<AISafetyInfoScreen> createState() => _AISafetyInfoScreenState();
}

class _AISafetyInfoScreenState extends State<AISafetyInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Optionally auto-navigate after delay
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/signup');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201A30),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/robot_ai.json', // You need to download and add this Lottie
                width: 250,
                height: 250,
                repeat: true,
              ),
              const SizedBox(height: 20),
              const Text(
                "Hi, I'm TIBEB AI 🤖",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "All posts are evaluated by AI to ensure quality and promote safe, respectful sharing.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
