import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/option_widget.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/options_enum.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/slider/slider_widget.dart';
import 'package:http/http.dart' as http;
import 'package:An_Smart_Farm_IOT/constants.dart';

import '../../utils/slider_utils.dart';

class ControlPanelPage extends StatefulWidget {
  final String tag;

  const ControlPanelPage({Key? key, required this.tag}) : super(key: key);

  @override
  _ControlPanelPageState createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  Options option = Options.temperature;
  double temp = 22.85;
  double humidity = 45.0;
  double soilMoisture = 30.0;
  double distance = 2;
  double light = 0;
  bool waterLevelStatus = false;
  bool soundStatus = false;
  bool fanStatus = false;
  bool pumpStatus = false;
  bool curtainStatus = false;
  bool automaticFan = false;
  bool automaticPump = false;
  bool automaticCurtain = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchSensorData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData() async {
    try {
      String hostname = await getMdnsHostname();
      final response = await http.get(Uri.parse('$hostname/data'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temp = (data['temperature'] as num).toDouble();
          humidity = (data['humidity'] as num).toDouble();
          soilMoisture = (data['soilMoisture'] as num).toDouble();
          distance = (data['distance'] as num).toDouble();
          light = (data['light'] as num).toDouble();
          waterLevelStatus = data['waterLevelStatus'] == 1;
          soundStatus = data['soundStatus'] == 1;
          fanStatus = data['fanStatus'] == 1;
          pumpStatus = data['pumpStatus'] == 1;
          curtainStatus = data['curtainStatus'] == 1;
          automaticFan = data['automaticFan'] == 1;
          automaticPump = data['automaticPump'] == 1;
          automaticCurtain = data['automaticCurtain'] == 1;
        });
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
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
              colors: [Colors.blueAccent, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              options(),
              const SizedBox(height: 20),
              slider(),
              const SizedBox(height: 20),
              sensorData(),
              const SizedBox(height: 20),
              statuses(),
            ],
          ),
        ),
      ),
    );
  }

  Widget options() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: Options.values.map((opt) {
        return OptionWidget(
          icon: _getOptionIcon(opt),
          size: 50,
          label: _getOptionLabel(opt),
          selected: option == opt,
          onTap: () {
            setState(() {
              option = opt;
            });
          },
        );
      }).toList(),
    );
  }

  IconData _getOptionIcon(Options opt) {
    switch (opt) {
      case Options.temperature:
        return Icons.thermostat;
      case Options.humidity:
        return Icons.water_drop;
      case Options.soilMoisture:
        return Icons.grass;
      case Options.distance:
        return Icons.straighten;
      default:
        return Icons.device_unknown;
    }
  }

  String _getOptionLabel(Options opt) {
    switch (opt) {
      case Options.temperature:
        return 'Temperature';
      case Options.humidity:
        return 'Humidity';
      case Options.soilMoisture:
        return 'Soil Moisture';
      case Options.distance:
        return 'Distance';
      default:
        return 'Unknown';
    }
  }

  Widget slider() {
    return Column(
      children: [
        Text(
          '${_getOptionLabel(option)}: ${_getSensorValue(option)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SliderWidget(
          progressVal: normalize(_getSensorValue(option), 0, 100),
          color: Colors.blueAccent,
          unit: _getUnit(option),
          realValue: _getSensorValue(option),
          onChange: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  double _getSensorValue(Options opt) {
    switch (opt) {
      case Options.temperature:
        return temp;
      case Options.humidity:
        return humidity;
      case Options.soilMoisture:
        return soilMoisture;
      case Options.distance:
        return distance;
      default:
        return 0.0;
    }
  }

  String _getUnit(Options opt) {
    switch (opt) {
      case Options.temperature:
        return '°C';
      case Options.humidity:
        return '%';
      case Options.soilMoisture:
        return '%';
      case Options.distance:
        return 'cm';
      default:
        return '';
    }
  }

  Widget sensorData() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        sensorCard('Temperature', '$temp °C'),
        sensorCard('Humidity', '$humidity %'),
        sensorCard('Soil Moisture', '$soilMoisture %'),
        sensorCard('Distance', '$distance cm'),
        sensorCard('Light', '$light lx'),
        sensorCard('Water Level', '$waterLevelStatus '),
        sensorCard('Sound', '$soundStatus'),
      ],
    );
  }

  Widget sensorCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }

  Widget statuses() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        statusCard('Fan', fanStatus),
        statusCard('Pump', pumpStatus),
        statusCard('Curtain', curtainStatus),
        statusCard('Automatic Fan', automaticFan),
        statusCard('Automatic Pump', automaticPump),
        statusCard('Automatic Curtain', automaticCurtain),
      ],
    );
  }

  Widget statusCard(String title, bool status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Icon(
              status ? Icons.check_circle : Icons.cancel,
              color: status ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
