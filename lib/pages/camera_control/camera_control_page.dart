import 'dart:math';

import 'package:flutter/material.dart';
import 'package:An_Smart_Farm_IOT/widgets/custom_appbar.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

final String flaskIp = '192.168.1.10:5000'; // Your Flask server IP address

class CameraControlPage extends StatefulWidget {
  @override
  _CameraControlPageState createState() => _CameraControlPageState();
}

class _CameraControlPageState extends State<CameraControlPage> with TickerProviderStateMixin {
  bool isActive = false;
  int speed = 1;
  double progressVal = 0.49;

  var activeColor = Rainbow(spectrum: [
    const Color(0xFF33C0BA),
    const Color(0xFF1086D4),
    const Color(0xFF6D04E2),
    const Color(0xFFC421A0),
    const Color(0xFFE4262F),
  ], rangeStart: 0.0, rangeEnd: 1.0);

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
            colors: <Color>[
              Colors.white,
              activeColor[progressVal].withOpacity(0.5),
              activeColor[progressVal],
            ],
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
                            stream: 'http://$flaskIp/stream',
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
                                onTap: () {
                                  // Handle capture action here
                                },
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
                                onTap: () {
                                  // Handle predict disease action here
                                },
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
                      // Joystick Control
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Joystick base
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.teal.withOpacity(0.3),
                                border: Border.all(color: Colors.teal, width: 2),
                              ),
                            ),
                            // Joystick knob
                            GestureDetector(
                              onPanUpdate: (details) {
                                // Handle joystick movement logic here
                                // Convert the local position to a direction
                                double dx = details.localPosition.dx - 75; // Center x
                                double dy = details.localPosition.dy - 75; // Center y
                                double angle = (dx == 0 && dy == 0) ? 0 : (dx >= 0 ? (dy >= 0 ? atan(dy / dx) : atan(dy / dx) + 2 * pi) : atan(dy / dx) + pi);
                                double radius = (details.localPosition - Offset(75, 75)).distance;

                                // Normalize the radius to not exceed the joystick radius
                                radius = radius > 75 ? 75 : radius;

                                // Send commands based on angle and radius (for demonstration purposes)
                                print('Angle: $angle, Radius: $radius');
                                // Here, send commands to your server based on angle and radius
                              },
                              onPanEnd: (details) {
                                // Reset joystick position when released
                                print('Joystick released');
                                // Reset command to stop movement
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.teal,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
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
