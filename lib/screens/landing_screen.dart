import 'package:flutter/material.dart';
import 'dart:async';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    // Start a timer to hide the splash screen after 5 seconds
    Timer(Duration(seconds: 5), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showSplash
            ? Center(
                child: Image.asset(
                  'assets/log.png', // Ensure the logo is correctly referenced in pubspec.yaml
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Logo not found',
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or Image
                  Center(
                    child: Image.asset(
                      'assets/log.png', // Ensure the path is correct and matches the asset in pubspec.yaml
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'Logo not found',
                          style: TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  // Welcome Message
                  Text(
                    'Welcome to ASL App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Enter App Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF0fae96), // Button background color
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 50.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Enter App',
                      style: TextStyle(
                        color: Colors.white, // Button text color
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
