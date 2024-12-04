import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:An_Smart_Farm_IOT/constants.dart';

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool isLoading = false;
  bool isCurtainOpen = false;
  bool isPumpOn = false;
  bool isAutomaticFan = false;
  bool isAutomaticCurtain = false;
  bool isAutomaticPump = false;
  double fanSpeed = 0;
  Timer? _debounce;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      String hostname = await getMdnsHostname();
      final response = await http.get(Uri.parse('$hostname/data'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isAutomaticFan = data['automaticFan'] == 1;
          isAutomaticCurtain = data['automaticCurtain'] == 1;
          isAutomaticPump = data['automaticPump'] == 1;
          isPumpOn = data['pumpStatus'] == 1;
          isCurtainOpen = data['curtainStatus'] == 1;
          fanSpeed = (data['fanStatus'] as num).toDouble(); // Handle numeric conversion safely
        });
      } else {
        showSnackbar('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      showSnackbar('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
      String hostname = await getMdnsHostname();
      final url = Uri.parse('$hostname/$endpoint');
      final response = await http.post(url, body: '');
      if (response.statusCode == 200) {
        fetchData();
      } else {
        showSnackbar('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      showSnackbar('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onFanSpeedChanged(double value) {
    setState(() {
      fanSpeed = value;
    });

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      sendCommand(
        'fan/set?speed=${value.round()}',
        'Setting Fan Speed to ${value.round()}',
      );
    });
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
                  status: isCurtainOpen ? "Open" : "Closed",
                  child: Switch(
                    value: isCurtainOpen,
                    onChanged: isAutomaticCurtain
                        ? null
                        : (value) {
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
                  status: '${fanSpeed.round()}',
                  child: Slider(
                    value: fanSpeed,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: fanSpeed.round().toString(),
                    onChanged: isAutomaticFan ? null : _onFanSpeedChanged,
                  ),
                ),
                controlCard(
                  icon: Icons.water_drop,
                  label: 'Pump',
                  color: Colors.green,
                  status: isPumpOn ? "On" : "Off",
                  child: Switch(
                    value: isPumpOn,
                    onChanged: isAutomaticPump
                        ? null
                        : (value) {
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
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget controlCard({
    required IconData icon,
    required String label,
    required Color color,
    required String status,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Status: $status',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 10),
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
