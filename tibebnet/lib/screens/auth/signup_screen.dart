import "package:flutter/material.dart";
// import 'package:tibebnet/screens/auth/login_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left:40.0,right:20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                GradientText(
                  text:"TibebNet",
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0CF2E0),
                      Color(0xFF078C82),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please fill the input below here",
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0x80FFFFFF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: const TextStyle(color: Color(0x80FFFFFF)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0x80FFFFFF)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0CF2E0)),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0x80FFFFFF),
                  ),
                  ),
                  style:TextStyle(color: Colors.white),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  enableSuggestions: false,
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Color(0x80FFFFFF)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0x80FFFFFF)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0CF2E0)),
                  ),
                  prefixIcon: const Icon(
                    Icons.mail,
                    weight: 20,
                    color: Color(0x80FFFFFF),
                  ),
                  ),
                  style:TextStyle(color: Colors.white),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: false,
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Color(0x80FFFFFF)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0x80FFFFFF)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0CF2E0)),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Color(0x80FFFFFF),
                    weight:20,
                  ),
                  ),
                  style:TextStyle(color: Colors.white),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: false,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                  labelText: "Confirm Password",
                  labelStyle: const TextStyle(color: Color(0x80FFFFFF)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0x80FFFFFF)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0CF2E0)),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    weight: 20,
                    color: Color(0x80FFFFFF),
                  ),
                  ),
                  style:TextStyle(color: Colors.white),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: false,
                  obscureText: true,
                ),
                const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CF2E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF0CF2E0).withOpacity(0.5),
                  minimumSize: const Size(250, 65), // Increased size
                  ),
                  child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                    ),
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 70),
              Center(child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CF2E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF0CF2E0).withOpacity(0.5),
             
                  ),
                  child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        '../../../assets/images/google.png',
                        height: 30,
                        width: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Sign Up with Google',
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
              SizedBox(height: 120),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Color(0x80FFFFFF),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const LoginPage(),
                        //   ),
                        // );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF0CF2E0),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
