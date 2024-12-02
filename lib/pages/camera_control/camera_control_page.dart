import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:An_Smart_Farm_IOT/widgets/custom_appbar.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:An_Smart_Farm_IOT/constants.dart';

class CameraControlPage extends StatefulWidget {
  @override
  _CameraControlPageState createState() => _CameraControlPageState();
}

class _CameraControlPageState extends State<CameraControlPage> {
  bool isActive = false;

  Future<void> captureImage() async {
    String hostname = await getMdnsHostname();
    final url = Uri.parse('$hostname/capture');
    final response = await http.get(url);
    print("Url : " + url.toString());

    if (response.statusCode == 200) {
      print("Image captured successfully!");
    } else {
      print("Failed to capture image.");
    }
  }

  Future<void> sendServoCommand(String direction) async {
    String hostname = await getMdnsHostname();
    final url = Uri.parse('$hostname/servo/$direction');
    final response = await http.post(url);
    print("Url : " + url.toString());
    if (response.statusCode == 200) {
      print("Servo moved $direction successfully!");
    } else {
      print("Failed to move servo $direction.");
    }
  }

  Future<void> predictDisease() async {
    String hostname = await getMdnsHostname();
    final url = Uri.parse('$hostname/predict');
    final response = await http.post(url);
    print("Url : " + url.toString());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      String predictedClass = jsonResponse['predicted_class'];
      double confidence = jsonResponse['confidence'];
      print("Prediction: $predictedClass, Confidence: $confidence%");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prediction: $predictedClass ($confidence%)")),
      );
    } else {
      print("Failed to get prediction.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.white, Colors.teal.withOpacity(0.5), Colors.teal],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Column(
              children: [
                const CustomAppBar(title: "Camera Control"),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                        ),
                        child: Center(
                          child: Mjpeg(
                            stream: '$mdnsHostname/stream',
                            isLive: true,
                            error: (context, error, stack) {
                              return Center(child: Text('Error: $error'));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: captureImage,
                                borderRadius: BorderRadius.circular(10),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Capture',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: predictDisease,
                                borderRadius: BorderRadius.circular(10),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Predict Disease',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Control Buttons
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => sendServoCommand('up'),
                            icon: Icon(Icons.arrow_upward, size: 50, color: Colors.teal),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => sendServoCommand('left'),
                                icon: Icon(Icons.arrow_back, size: 50, color: Colors.teal),
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                onPressed: () => sendServoCommand('right'),
                                icon: Icon(Icons.arrow_forward, size: 50, color: Colors.teal),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => sendServoCommand('down'),
                            icon: Icon(Icons.arrow_downward, size: 50, color: Colors.teal),
                          ),
                        ],
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
