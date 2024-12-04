import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:An_Smart_Farm_IOT/constants.dart';

class CameraControlPage extends StatefulWidget {
  @override
  _CameraControlPageState createState() => _CameraControlPageState();
}

class _CameraControlPageState extends State<CameraControlPage> {
  bool isDisposed = false;
  bool isCapturing = false;
  bool isPredicting = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  Future<void> captureImage() async {
    if (isDisposed) return;
    setState(() {
      isCapturing = true;
    });

    try {
      String hostname = await getMdnsHostname();
      final url = Uri.parse('$hostname/capture');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image captured successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to capture image.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<void> sendServoCommand(String direction) async {
    if (isDisposed) return;
    try {
      String hostname = await getMdnsHostname();
      final url = Uri.parse('$hostname/servo/$direction');
      await http.post(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending servo command: $e")),
      );
    }
  }

  Future<void> predictDisease() async {
    if (isDisposed) return;
    setState(() {
      isPredicting = true;
    });

    try {
      String hostname = await getMdnsHostname();
      final url = Uri.parse('$hostname/predict');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        String predictedClass = jsonResponse['predicted_class'];
        double confidence = jsonResponse['confidence'];

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Prediction",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Class: $predictedClass",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Confidence: ${confidence.toStringAsFixed(2)}%",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to get prediction.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isPredicting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera Control"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
      colors: [Colors.white, Colors.teal.withOpacity(0.1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    ),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    Expanded(
    child: Container(
    decoration: BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
    BoxShadow(
    color: Colors.black26,
    blurRadius: 8,
    offset: Offset(2, 2),
    ),
    ],
    ),
    child: isDisposed
    ? Center(
    child: Text(
    'Stream is not available',
    style: TextStyle(color: Colors.white),
    ),
    )
        : ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Mjpeg(
        stream: '$mdnsHostname/stream',
        isLive: true,
        error: (context, error, stack) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
    ),
    ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildActionButton(
            onPressed: isCapturing ? null : captureImage,
            icon: Icons.camera_alt,
            label: 'Capture',
            isLoading: isCapturing,
          ),
          buildActionButton(
            onPressed: isPredicting ? null : predictDisease,
            icon: Icons.search,
            label: 'Predict',
            isLoading: isPredicting,
          ),
        ],
      ),
      SizedBox(height: 20),
      Column(
        children: [
          IconButton(
            onPressed: () => sendServoCommand('up'),
            icon: Icon(Icons.arrow_upward, size: 40, color: Colors.teal),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => sendServoCommand('left'),
                icon: Icon(Icons.arrow_back, size: 40, color: Colors.teal),
              ),
              SizedBox(width: 20),
              IconButton(
                onPressed: () => sendServoCommand('right'),
                icon: Icon(Icons.arrow_forward, size: 40, color: Colors.teal),
              ),
            ],
          ),
          IconButton(
            onPressed: () => sendServoCommand('down'),
            icon: Icon(Icons.arrow_downward, size: 40, color: Colors.teal),
          ),
        ],
      ),
    ],
    ),
    ),
      ),
    );
  }

  Widget buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      icon: isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Icon(icon, size: 24),
      label: Text(
        label,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
