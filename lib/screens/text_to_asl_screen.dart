import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:ui'; // Import for PointMode

void main() {
  runApp(MaterialApp(home: TextToASL()));
}

class TextToASL extends StatefulWidget {
  @override
  _TextToASLState createState() => _TextToASLState();
}

class _TextToASLState extends State<TextToASL> {
  final _textController = TextEditingController();
  Map<String, List<dynamic>> _gestureData = {};
  bool _isLoading = false;
  int _currentFrameIndex = 0;
  List<dynamic> _frames = [];
  String _currentGestureName = ''; // To store the current gesture name

  @override
  void initState() {
    super.initState();
    _loadGestureData();
  }

  Future<void> _loadGestureData() async {
    final String response =
        await rootBundle.loadString('assets/reference.json');
    final data = await json.decode(response);
    setState(() {
      _gestureData = Map<String, List<dynamic>>.from(data);
    });
  }

  Future<void> _submitText() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    String text = _textController.text.trim();
    if (text.isEmpty || _gestureData.isEmpty) return;

    setState(() {
      _isLoading = true;
      _frames = [];
      _currentFrameIndex = 0;
      _currentGestureName = ''; // Reset gesture name
    });

    try {
      final words = text.split(' ');
      for (var word in words) {
        if (_gestureData.containsKey(word)) {
          for (var frame in _gestureData[word]!) {
            _frames.add({'name': word, 'frame': frame});
          }
        } else {
          print("No gesture data found for word: $word");
          // If the word is not found, split it into characters
          for (var char in word.split('')) {
            if (_gestureData.containsKey(char)) {
              for (var frame in _gestureData[char]!) {
                _frames.add({'name': char, 'frame': frame});
              }
            } else {
              print("No gesture data found for character: $char");
            }
          }
        }
      }
      _animateGestures();
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _animateGestures() {
    if (_frames.isEmpty) return;

    const frameDuration = Duration(milliseconds: 50); // Slow down to 10 fps
    _currentFrameIndex = 0;

    Future.doWhile(() async {
      if (_currentFrameIndex < _frames.length) {
        await Future.delayed(frameDuration);
        setState(() {
          _currentGestureName = _frames[_currentFrameIndex]['name'];
          _currentFrameIndex++;
        });
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20), // Add some space at the top
            // Custom Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 50, // Square button width
                height: 50, // Square button height
                decoration: BoxDecoration(
                  color: Color(0xFF0fae96), // Button background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: IconButton(
                  icon:
                      Icon(Icons.arrow_back, color: Colors.white), // White icon
                  onPressed: () {
                    Navigator.of(context).pop(); // Back button functionality
                  },
                ),
              ),
            ),
            SizedBox(height: 20), // Spacing after the back button
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: "Enter text",
                labelStyle: TextStyle(color: Colors.white), // Label text color
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Underline color when enabled
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Underline color when focused
                ),
              ),
              style: TextStyle(color: Colors.white), // Text color in TextField
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF0fae96), // Background color #0fae96
                      padding: EdgeInsets.symmetric(vertical: 16.0), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                    // icon: Icon(Icons.enter,
                    //     color: Colors.white), // You can choose any icon
                    label: Text(
                      "Submit Text",
                      style: TextStyle(color: Colors.white), // Text color white
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Center(
              child: Text(
                _currentGestureName, // Display the current gesture name
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold, // Make the text bold
                  color: Color(
                      0xFF0fae96), // Use the same color as the submit button
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: Center(
                      child: _frames.isNotEmpty &&
                              _currentFrameIndex < _frames.length
                          ? CustomPaint(
                              size: Size(300, 300),
                              painter: GesturePainter(
                                _frames[_currentFrameIndex]['frame'],
                              ),
                            )
                          : Text(
                              "No gestures to display.",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white), // Text color
                            ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class GesturePainter extends CustomPainter {
  final dynamic frame;

  GesturePainter(this.frame);

  @override
  void paint(Canvas canvas, Size size) {
    if (frame == null) return;

    final gestureColor = Color(0xFF0fae96); // Gesture color #0fae96

    final paint = Paint()
      ..color = gestureColor
      ..strokeWidth = 6.0 // Adjusted stroke width for better clarity
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = gestureColor
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill; // Filled circles for better visibility

    if (frame['Left Hand Coordinates'] != null) {
      _drawHand(
          canvas, size, frame['Left Hand Coordinates'], paint, circlePaint);
    }

    if (frame['Right Hand Coordinates'] != null) {
      _drawHand(
          canvas, size, frame['Right Hand Coordinates'], paint, circlePaint);
    }
  }

  void _drawHand(Canvas canvas, Size size, List<dynamic> handCoordinates,
      Paint paint, Paint circlePaint) {
    if (handCoordinates == null) return;

    List<Offset> points = [];

    // Calculate scaling factors to fit within the canvas
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    // Determine the bounding box of the original coordinates
    for (var point in handCoordinates) {
      if (point is Map<String, dynamic> &&
          point.containsKey('Coordinates') &&
          point['Coordinates'] is List<dynamic> &&
          point['Coordinates'].length >= 2) {
        final x = point['Coordinates'][0];
        final y = point['Coordinates'][1];

        if (x is double && y is double) {
          minX = x < minX ? x : minX;
          maxX = x > maxX ? x : maxX;
          minY = y < minY ? y : minY;
          maxY = y > maxY ? y : maxY;
        }
      }
    }

    // Calculate the scale factor based on the bounding box and canvas size
    double scaleX = size.width / (maxX - minX);
    double scaleY = size.height / (maxY - minY);
    double scale =
        (scaleX < scaleY ? scaleX : scaleY) * 0.5; // Reduce the size by 50%

    // Center the gestures in the canvas
    double offsetX = (size.width - (maxX - minX) * scale) / 2 - minX * scale;
    double offsetY = (size.height - (maxY - minY) * scale) / 2 - minY * scale;

    // Scale and translate the coordinates
    for (var point in handCoordinates) {
      if (point is Map<String, dynamic> &&
          point.containsKey('Coordinates') &&
          point['Coordinates'] is List<dynamic> &&
          point['Coordinates'].length >= 2) {
        final x = point['Coordinates'][0];
        final y = point['Coordinates'][1];

        if (x is double && y is double) {
          final scaledX = x * scale + offsetX;
          final scaledY = y * scale + offsetY;

          points.add(Offset(scaledX, scaledY));
          canvas.drawCircle(
            Offset(scaledX, scaledY),
            2.0, // Joint size
            circlePaint,
          );
        } else {
          print("Invalid data types for x or y in point: $point");
        }
      } else {
        print(
            "Invalid point structure or missing 'Coordinates' keys in point: $point");
      }
    }

    if (points.isNotEmpty) {
      // Draw hand structure using Bezier curves for smooth representation
      final path = Path();

      // Smoothly connect points using Bezier curves
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        final p = points[i];
        path.quadraticBezierTo(
          (points[i - 1].dx + p.dx) / 2,
          (points[i - 1].dy + p.dy) / 2,
          p.dx,
          p.dy,
        );
      }

      canvas.drawPath(path, paint..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
