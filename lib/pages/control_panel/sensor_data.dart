import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/option_widget.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/options_enum.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/slider/slider_widget.dart';
import 'package:http/http.dart' as http;
import 'package:An_Smart_Farm_IOT/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../utils/slider_utils.dart';

class ControlPanelPage extends StatefulWidget {
  final String tag;

  const ControlPanelPage({Key? key, required this.tag}) : super(key: key);

  @override
  _ControlPanelPageState createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Options option = Options.temperature;
  double temp = 22.85;
  double humidity = 45.0;
  double soilMoisture = 30.0;
  double distance = 2;
  double light = 0;
  double waterLevelStatus = 0;
  double soundStatus = 0;
  bool fanStatus = false;
  bool pumpStatus = false;
  bool curtainStatus = false;
  bool automaticFan = false;
  bool automaticPump = false;
  bool automaticCurtain = false;
  Timer? _timer;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchSensorData();
    });
    _notificationTimer = Timer.periodic(Duration(minutes: 20), (timer) {
      checkAndSendNotification();
    });
    initializeNotifications();
  }

  void initializeNotifications() {
    final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void checkAndSendNotification() {
    String alertMessage = '';

    if (temp > 33) {
      alertMessage += 'Temperature is too high: $temp°C. ';
    }
    if (distance >= 20) {
      alertMessage += 'Out of water in tank : $distance cm. ';
    }
    if (soilMoisture >= 3200) {
      alertMessage += 'Soil moisture is too high: $soilMoisture. ';
    }

    if (alertMessage.isNotEmpty) {
      sendNotification(alertMessage);
    }
  }

  void sendNotification(String message) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'sensor_alerts_channel',
      'Sensor Alerts',
      channelDescription: 'Notifications for sensor value alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Sensor Alert',
      message,
      platformChannelSpecifics,
      payload: 'sensor_alert',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorData() async {
    try {
      String hostname = await getMdnsHostname();
      final response = await http.get(Uri.parse('$hostname/data'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temp = (data['temperature'] as num?)?.toDouble() ?? 0.0;
          humidity = (data['humidity'] as num?)?.toDouble() ?? 0.0;
          soilMoisture = (data['soilMoisture'] as num?)?.toDouble() ?? 0.0;
          distance = (data['distance'] as num?)?.toDouble() ?? 0.0;
          light = (data['light'] as num?)?.toDouble() ?? 0.0;
          waterLevelStatus = (data['waterLevel'] as num?)?.toDouble() ?? 0.0;
          soundStatus = (data['soundStatus'] as num?)?.toDouble() ?? 0.0;
          fanStatus = (data['fanStatus'] as int?) == 1;
          pumpStatus = (data['pumpStatus'] as int?) == 1;
          curtainStatus = (data['curtainStatus'] as int?) == 1;
          automaticFan = (data['automaticFan'] as int?) == 1;
          automaticPump = (data['automaticPump'] as int?) == 1;
          automaticCurtain = (data['automaticCurtain'] as int?) == 1;
          print('State updated');
        });
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getOptionLabel(option)}: ${_getSensorValue(option)} ${_getUnit(option)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SliderWidget(
          progressVal: normalize(_getSensorValue(option), 0, 100),
          color: _getOptionColor(option),
          unit: _getUnit(option),
          realValue: _getSensorValue(option),
          onChange: (value) {
            setState(() {
              // Update value if needed
            });
          },
        ),
      ],
    );
  }

  Color _getOptionColor(Options opt) {
    switch (opt) {
      case Options.temperature:
        return Colors.orange;
      case Options.humidity:
        return Colors.blue;
      case Options.soilMoisture:
        return Colors.green;
      case Options.distance:
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
        sensorCard('🌡️ Temperature', '$temp °C', Colors.orange),
        sensorCard('💧 Humidity', '$humidity %', Colors.blue),
        sensorCard('🌱 Soil Moisture', '$soilMoisture', Colors.green),
        sensorCard('📏 Tank Depth', '$distance cm', Colors.purple),
        sensorCard('🔆 Light', '$light lx', Colors.yellow),
        sensorCard('💧 Water Level', '$waterLevelStatus', Colors.teal),
        sensorCard('🔊 Sound', '$soundStatus', Colors.red),
      ],
    );
  }

  Widget sensorCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      shadowColor: color.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
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
        statusCard('Fan', fanStatus, Colors.green),
        statusCard('Pump', pumpStatus, Colors.teal),
        statusCard('Curtain', curtainStatus, Colors.orange),
        statusCard('Auto Fan', automaticFan, Colors.purple),
        statusCard('Auto Pump', automaticPump, Colors.blue),
        statusCard('Auto Curtain', automaticCurtain, Colors.yellow),
      ],
    );
  }

  Widget statusCard(String title, bool status, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      shadowColor: color.withOpacity(0.4),
      child: ListTile(
        leading: Icon(
          status ? Icons.check_circle : Icons.cancel,
          color: status ? color : Colors.red,
          size: 30,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          status ? 'ON' : 'OFF',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: status ? color : Colors.red),
        ),
      ),
    );
  }
}