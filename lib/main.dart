import 'package:flutter/material.dart';
import 'screens/landing_screen.dart'; // Import the LandingScreen file
import 'screens/home_screen.dart'; // Import the HomeScreen file
import 'screens/text_to_asl_screen.dart'; // Import the TextToASL file
import 'screens/audio_to_asl_screen.dart'; // Import the AudioToASL file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASL App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black, // Set global background color
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: LandingScreen(), // Set the LandingScreen as the initial screen
      routes: {
        '/home': (context) => HomeScreen(), // Route for HomeScreen
        '/text-to-asl': (context) => TextToASL(), // Route for TextToASL
        '/audio-to-asl': (context) => AudioToASL(), // Route for AudioToASL
      },
    );
  }
}
