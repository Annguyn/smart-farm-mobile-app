import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/option_widget.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/options_enum.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/power_widget.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/slider/slider_widget.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/speed_widget.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/temp_widget.dart';
import 'package:An_Smart_Farm_IOT/utils/slider_utils.dart';
import 'package:An_Smart_Farm_IOT/widgets/custom_appbar.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:http/http.dart' as http;
import 'package:An_Smart_Farm_IOT/constants.dart';

class ControlPanelPage extends StatefulWidget {
  final String tag;

  const ControlPanelPage({Key? key, required this.tag}) : super(key: key);
  @override
  _ControlPanelPageState createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> with TickerProviderStateMixin {
  Options option = Options.temperature;
  bool isActive = false;
  int speed = 1;
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
  double progressVal = 0.49;
  var activeColor = Rainbow(spectrum: [
    const Color(0xFF33C0BA),
    const Color(0xFF1086D4),
    const Color(0xFF6D04E2),
    const Color(0xFFC421A0),
    const Color(0xFFE4262F)
  ], rangeStart: 0.0, rangeEnd: 1.0);

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    try {
      String hostname = await getMdnsHostname();
      final response = await http.get(Uri.parse('$hostname/data'));
      print("Url : " + Uri.parse('$hostname/data').toString());
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
        // Print values to debug
        print('Temperature: $temp');
        print('Humidity: $humidity');
        print('Soil Moisture: $soilMoisture');
        print('Distance: $distance');
        print('Light: $light');
        print('Water Level Status: $waterLevelStatus');
        print('Sound Status: $soundStatus');
        print('Fan Status: $fanStatus');
        print('Pump Status: $pumpStatus');
        print('Curtain Status: $curtainStatus');
        print('Automatic Fan: $automaticFan');
        print('Automatic Pump: $automaticPump');
        print('Automatic Curtain: $automaticCurtain');
      } else {
        print('Failed to load sensor data');
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Sensor Data'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }

  Widget options() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        OptionWidget(
          icon: Icons.thermostat,
          size: 50,
          label: 'Temperature',
          selected: option == Options.temperature,
          onTap: () {
            setState(() {
              option = Options.temperature;
            });
          },
        ),
        OptionWidget(
          icon: Icons.water_drop,
          size: 50,
          label: 'Humidity',
          selected: option == Options.humidity,
          onTap: () {
            setState(() {
              option = Options.humidity;
            });
          },
        ),
        OptionWidget(
          icon: Icons.grass,
          size: 50,
          label: 'Soil Moisture',
          selected: option == Options.soilMoisture,
          onTap: () {
            setState(() {
              option = Options.soilMoisture;
            });
          },
        ),
        OptionWidget(
          icon: Icons.straighten,
          size: 50,
          label: 'Distance',
          selected: option == Options.distance,
          onTap: () {
            setState(() {
              option = Options.distance;
            });
          },
        ),
      ],
    );
  }

  Widget slider() {
    double value;
    String unit;
    switch (option) {
      case Options.temperature:
        value = temp;
        unit = "°C";
        progressVal = normalize(temp, kMinTemperature, kMaxTemperature);
        break;
      case Options.humidity:
        value = humidity;
        unit = "%";
        progressVal = normalize(humidity, kMinHumidity, kMaxHumidity);
        break;
      case Options.soilMoisture:
        value = soilMoisture;
        unit = "%";
        progressVal = normalize(soilMoisture, kMinSoilMoisture, kMaxSoilMoisture);
        break;
      case Options.distance:
        value = distance;
        unit = "cm";
        progressVal = normalize(distance, kMinDistance, kMaxDistance);
        break;
      default:
        value = 0.0;
        unit = "";
    }

    return Column(
      children: [
        SliderWidget(
          progressVal: progressVal,
          color: activeColor[progressVal],
          onChange: (val) {
            setState(() {
              progressVal = normalize(val, kMinTemperature, kMaxTemperature); // Change based on selected option
            });
          },
          unit: unit,
          realValue: value,
        ),
      ],
    );
  }

  Widget sensorData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensor Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            sensorCard('Temperature', '$temp °C'),
            sensorCard('Humidity', '$humidity %'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            sensorCard('Soil Moisture', '$soilMoisture %'),
            sensorCard('Light', '$light lx'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            sensorCard('Distance', '$distance cm'),
            sensorCard('Water Level', waterLevelStatus ? 'Full' : 'Empty'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            sensorCard('Sound', soundStatus ? 'Detected' : 'Not Detected'),
          ],
        ),
      ],
    );
  }


  Widget sensorCard(String title, String value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget statuses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statuses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            statusCard('Fan', fanStatus),
            statusCard('Pump', pumpStatus),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            statusCard('Curtain', curtainStatus),
            statusCard('Automatic Fan', automaticFan),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            statusCard('Automatic Pump', automaticPump),
            statusCard('Automatic Curtain', automaticCurtain),
          ],
        ),
      ],
    );
  }


  Widget statusCard(String title, bool status) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(status ? 'Active' : 'Inactive', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}