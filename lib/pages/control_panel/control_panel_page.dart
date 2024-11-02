import 'dart:convert';
import 'package:animated_background/animated_background.dart';
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


class ControlPanelPage extends StatefulWidget {
  final String tag;

  const ControlPanelPage({Key? key, required this.tag}) : super(key: key);
  @override
  _ControlPanelPageState createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage>
    with TickerProviderStateMixin {
  Options option = Options.temperature;
  bool isActive = false;
  int speed = 1;
  double temp = 22.85;
  double humidity = 45.0;
  double soilMoisture = 30.0;
  double distance = 2;
  double progressVal = 0.49;
  String flaskIp = "192.168.1.7:5000";
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
      final response = await http.get(Uri.parse('http://$flaskIp/sensor'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temp = data['temperature'];
          humidity = data['humidity'];
          soilMoisture = data['soil_moisture'];
          distance = data['distance'];
        });
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
              activeColor[progressVal]
            ],
          ),
        ),
        child: AnimatedBackground(
          behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
              baseColor: const Color(0xFFFFFFFF),
              opacityChangeRate: 0.25,
              minOpacity: 0.1,
              maxOpacity: 0.3,
              spawnMinSpeed: speed * 60.0,
              spawnMaxSpeed: speed * 120,
              spawnMinRadius: 2.0,
              spawnMaxRadius: 5.0,
              particleCount: isActive ? speed * 150 : 0,
            ),
          ),
          vsync: this,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Column(
                children: [
                  const CustomAppBar(title: "Smart Sensor"),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        options(),
                        slider(),
                        controls(),
                      ],
                    ),
                  )
                ],
              ),
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
          icon: 'assets/svg/temperature-three-quarters-solid.svg',
          isSelected: option == Options.temperature,
          onTap: () => setState(() {
            option = Options.temperature;
            fetchSensorData();
          }),
          size: 32,
        ),
        OptionWidget(
          icon: 'assets/svg/humidity-svgrepo-com.svg',
          isSelected: option == Options.humidity,
          onTap: () => setState(() {
            option = Options.humidity;
            fetchSensorData();
          }),
          size: 25,
        ),
        OptionWidget(
          icon: 'assets/svg/bridge-water-solid.svg',
          isSelected: option == Options.soilMoisture,
          onTap: () => setState(() {
            option = Options.soilMoisture;
            fetchSensorData();
          }),
          size: 35,
        ),
        OptionWidget(
          icon: 'assets/svg/lightbulb-regular.svg',
          isSelected: option == Options.lightSensor,
          onTap: () => setState(() {
            option = Options.lightSensor;
            fetchSensorData();
          }),
          size: 28,
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
      case Options.lightSensor:
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
          realValue: value, // Pass the real value here
        ),
      ],
    );
  }




  Widget controls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SpeedWidget(
                speed: speed,
                changeSpeed: (val) => setState(() {
                  speed = val;
                }),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: PowerWidget(
                isActive: isActive,
                onChanged: (val) async {
                  setState(() {
                    isActive = val;
                  });

                  String action = isActive ? 'on' : 'off';
                  String url = 'http://$flaskIp/control';

                  try {
                    final response = await http.post(
                      Uri.parse(url),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'action': isActive ? 'on' : 'off'}),
                    );

                    if (response.statusCode == 200) {
                      print('Action ${isActive ? 'on' : 'off'} successful');
                    } else {
                      print('Failed to perform action ${isActive ? 'on' : 'off'}');
                    }
                  } catch (e) {
                    print('Error performing action ${isActive ? 'on' : 'off'}: $e');
                  }

                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // TempWidget(
        //   temp: temp,
        //   changeTemp: (val) => setState(() {
        //     temp = val;
        //     progressVal = normalize(val, kMinDegree, kMaxDegree);
        //   }),
        // ),
        const SizedBox(height: 15),
      ],
    );
  }
}