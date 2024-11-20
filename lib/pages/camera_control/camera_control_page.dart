import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:An_Smart_Farm_IOT/widgets/custom_appbar.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:An_Smart_Farm_IOT/constants.dart';

class CameraControlPage extends StatefulWidget {
  @override
  _CameraControlPageState createState() => _CameraControlPageState();
}

class _CameraControlPageState extends State<CameraControlPage> with TickerProviderStateMixin {
  bool isActive = false;
  bool _isSendingCommand = false;
  int speed = 1;
  double progressVal = 0.49;
  var activeColor = Rainbow(spectrum: [
    const Color(0xFF33C0BA),
    const Color(0xFF1086D4),
    const Color(0xFF6D04E2),
    const Color(0xFFC421A0),
    const Color(0xFFE4262F),
  ], rangeStart: 0.0, rangeEnd: 1.0);

  Future<void> captureImage() async {
    final url = Uri.parse('http://$flaskIp/capture');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("Image captured successfully!");
    } else {
      print("Failed to capture image.");
    }
  }

  Future<void> sendServoCommand(String direction) async {
    final url = Uri.parse('http://$flaskIp/servo/$direction');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print("Servo moved $direction successfully!");
    } else {
      print("Failed to move servo $direction.");
    }
  }

  Future<void> predictDisease() async {
    final url = Uri.parse('http://$flaskIp/predict');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      String predictedClass = jsonResponse['predicted_class'];
      double confidence = jsonResponse['confidence'];
      print("Prediction: $predictedClass, Confidence: $confidence%");

      // Optionally display the result to the user
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Prediction: $predictedClass ($confidence%)"))
      );
    } else {
      print("Failed to get prediction.");
    }
  }

  // Improved Joystick Control
  Offset _knobPosition = Offset(75, 75);

  void _handlePanUpdate(DragUpdateDetails details) async {
    final Offset center = Offset(75, 75); // Tâm joystick
    Offset newPosition = details.localPosition;

    // Giới hạn di chuyển trong vòng tròn bán kính 75
    final double distance = (newPosition - center).distance;
    if (distance > 75) {
      final angle = atan2(newPosition.dy - center.dy, newPosition.dx - center.dx);
      newPosition = Offset(
        center.dx + 75 * cos(angle),
        center.dy + 75 * sin(angle),
      );
    }

    setState(() {
      _knobPosition = newPosition;
    });

    // Gửi lệnh theo hướng joystick
    if (!_isSendingCommand) {
      _isSendingCommand = true; // Đặt cờ để chặn gửi lệnh liên tiếp

      // Xác định hướng
      final dx = newPosition.dx - center.dx;
      final dy = newPosition.dy - center.dy;
      final angle = atan2(dy, dx);

      if (angle >= -pi / 4 && angle < pi / 4) {
        await sendServoCommand('right');
      } else if (angle >= pi / 4 && angle < 3 * pi / 4) {
        await sendServoCommand('down');
      } else if (angle >= -3 * pi / 4 && angle < -pi / 4) {
        await sendServoCommand('up');
      } else {
        await sendServoCommand('left');
      }

      // Thêm độ trễ trước khi cho phép gửi lệnh tiếp theo
      await Future.delayed(Duration(milliseconds: 300)); // Thời gian trễ 300ms
      _isSendingCommand = false; // Đặt lại cờ
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _knobPosition = Offset(75, 75); // Reset knob về vị trí trung tâm
    });
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
                            Positioned(
                              left: _knobPosition.dx - 25, // Bán kính knob = 25
                              top: _knobPosition.dy - 25,
                              child: GestureDetector(
                                onPanUpdate: _handlePanUpdate,
                                onPanEnd: _handlePanEnd,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.teal,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
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
