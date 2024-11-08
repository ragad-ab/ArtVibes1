import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to AuthScreen or HomeScreen after 5 seconds based on auth status
    Future.delayed(Duration(seconds: 5), () {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned(
            left: -30, // Shift image to the left
            child: Image.asset(
              'assets/images/welcome.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width + 40,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo at the top
              Center(
                child: Image.asset(
                  'assets/images/Art_vibes_Logo.png',
                  height: 150, // Set logo size
                ),
              ),
              const SizedBox(height: 100), // Spacing between logo and text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "Welcome to ARTVIBES\n\"Where creativity thrives and imagination comes alive\".",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 29, // Font size adjusted for better balance
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
