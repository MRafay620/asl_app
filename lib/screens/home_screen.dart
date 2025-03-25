import 'package:asl_app/screens/audio_to_asl_screen.dart';
import 'package:asl_app/screens/text_to_asl_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar to eliminate the title bar
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add a logo above the buttons
              Image.asset(
                'assets/log.png', // Replace with the path to your logo asset
                height: 100,
              ),
              SizedBox(height: 20), // Space between logo and buttons
              Padding(
                padding: EdgeInsets.all(16.0), // Padding outside the container
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.teal, width: 8.0), // Thicker border
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(16.0), // Padding inside the container
                  child: Column(
                    children: [
                      SizedBox(
                        width:
                            double.infinity, // Make button take the full width
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/text-to-asl');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.teal, // Button background color
                            padding: EdgeInsets.symmetric(
                              vertical: 20.0, // Button height
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color: Colors.teal,
                                  width: 4.0), // Button border thickness
                            ),
                          ),
                          child: Text(
                            'Text to Sign',
                            style: TextStyle(
                              color: Colors.white, // Button text color
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Space between buttons
                      SizedBox(
                        width:
                            double.infinity, // Make button take the full width
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/audio-to-asl');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.teal, // Button background color
                            padding: EdgeInsets.symmetric(
                              vertical: 20.0, // Button height
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color: Colors.teal,
                                  width: 4.0), // Button border thickness
                            ),
                          ),
                          child: Text(
                            'Audio to Sign',
                            style: TextStyle(
                              color: Colors.white, // Button text color
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
    routes: {
      '/text-to-asl': (context) => TextToASL(), // Define your screens here
      '/audio-to-asl': (context) => AudioToASL(), // Define your screens here
    },
  ));
}

class TextToAslScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to ASL'),
      ),
      body: Center(
        child: Text('Text to ASL screen content goes here'),
      ),
    );
  }
}

class AudioToAslScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio to ASL'),
      ),
      body: Center(
        child: Text('Audio to ASL screen content goes here'),
      ),
    );
  }
}
