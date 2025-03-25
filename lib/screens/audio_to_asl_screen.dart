import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MaterialApp(home: AudioToASL()));
}

class AudioToASL extends StatefulWidget {
  @override
  _AudioToASLState createState() => _AudioToASLState();
}

class _AudioToASLState extends State<AudioToASL> {
  final _textController = TextEditingController();
  Map<String, List<dynamic>> _gestureData = {};
  bool _isLoading = false;
  int _currentFrameIndex = 0;
  List<dynamic> _frames = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcription = '';
  double _confidence = 1.0;
  String _currentGestureName = '';

  @override
  void initState() {
    super.initState();
    _loadGestureData();
    _startListening(); // Automatically start listening when the app initializes
  }

  Future<void> _loadGestureData() async {
    final String response =
        await rootBundle.loadString('assets/reference.json');
    final data = await json.decode(response);
    setState(() {
      _gestureData = Map<String, List<dynamic>>.from(data);
    });
  }

  Future<void> _startListening() async {
    if (await _requestPermission()) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          // Automatically stop listening after some time or a condition
          if (_isListening && val == 'done') {
            _stopListening();
          }
        },
        onError: (val) => print('onError: $val'),
        debugLogging: true,
      );

      if (available) {
        setState(() {
          _isListening = true;
          _transcription = '';
        });

        _speech.listen(
          onResult: (val) {
            setState(() {
              _transcription = val.recognizedWords;
              _textController.text = _transcription;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            });

            // Automatically stop listening if transcription meets some condition
            if (_transcription.isNotEmpty && val.finalResult) {
              _stopListening();
              _transcribe(); // Process the transcription automatically
            }
          },
          listenFor: Duration(minutes: 2),
          pauseFor: Duration(seconds: 5),
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        print("Speech recognition not available");
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      await Permission.microphone.request();
      status = await Permission.microphone.status;
    }
    return status.isGranted;
  }

  Future<void> _transcribe() async {
    setState(() {
      _textController.text = _transcription;
      print("Text Controller Updated: ${_textController.text}");
    });
    _submitText();
  }

  Future<void> _submitText() async {
    String text = _textController.text.trim();
    if (text.isEmpty || _gestureData.isEmpty) {
      print("Text is empty or gesture data not loaded.");
      return;
    }

    setState(() {
      _isLoading = true;
      _frames = [];
      _currentFrameIndex = 0;
      _currentGestureName = '';
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
      print("Error in _submitText: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _animateGestures() {
    if (_frames.isEmpty) {
      print("No frames to animate.");
      return;
    }

    const frameDuration = Duration(milliseconds: 50);
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
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Custom Back Button
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF0fae96),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.grey[850],
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  _transcription.isNotEmpty
                      ? _transcription
                      : "Recognized text will appear here",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? null : _startListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0fae96),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    icon: Icon(Icons.mic, color: Colors.white),
                    label: Text(
                      _isListening ? "Listening..." : "Start Listening",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? _stopListening : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFf44336),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    icon: Icon(Icons.stop, color: Colors.white),
                    label: Text(
                      "Stop Listening",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _transcribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4caf50),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    icon: Icon(Icons.translate, color: Colors.white),
                    label: Text(
                      "Show Gestures",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _currentGestureName.isNotEmpty
                    ? "Current Gesture: $_currentGestureName"
                    : "No gesture recognized.",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0fae96),
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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
      ..strokeWidth = 2.0 // Adjusted stroke width for better clarity
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = gestureColor
      ..strokeWidth = 2.0
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
    double scale = scaleX < scaleY ? scaleX : scaleY;

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
            4.0, // Joint size
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
