import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:An_Smart_Farm_IOT/constants.dart';

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool isLoading = false;
  bool isCurtainOpen = false;
  bool isPumpOn = false;
  double fanSpeed = 1;

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> sendCommand(String endpoint, String message) async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('http://$flaskIp/$endpoint');
      final response = await http.post(url, body: '');
      final responseData = json.decode(response.body);
      showSnackbar(responseData['message']);
    } catch (e) {
      showSnackbar('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Panel'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                controlCard(
                  icon: Icons.curtains,
                  label: 'Curtain',
                  color: Colors.orange,
                  child: Switch(
                    value: isCurtainOpen,
                    onChanged: (value) {
                      setState(() {
                        isCurtainOpen = value;
                      });
                      sendCommand(
                        value ? 'curtain/open' : 'curtain/close',
                        value ? 'Opening Curtain' : 'Closing Curtain',
                      );
                    },
                  ),
                ),
                controlCard(
                  icon: Icons.speed,
                  label: 'Fan Speed',
                  color: Colors.blue,
                  child: Slider(
                    value: fanSpeed,
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: fanSpeed.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        fanSpeed = value;
                      });
                      int speed = (value == 1) ? 100 : (value == 2) ? 200 : 255;
                      sendCommand(
                        'fan/set?speed=$speed',
                        'Setting Fan Speed to $speed',
                      );
                    },
                  ),
                ),
                controlCard(
                  icon: Icons.water_drop,
                  label: 'Pump',
                  color: Colors.green,
                  child: Switch(
                    value: isPumpOn,
                    onChanged: (value) {
                      setState(() {
                        isPumpOn = value;
                      });
                      sendCommand(
                        value ? 'pump/on' : 'pump/off',
                        value ? 'Turning On Pump' : 'Turning Off Pump',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget controlCard({
    required IconData icon,
    required String label,
    required Color color,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}