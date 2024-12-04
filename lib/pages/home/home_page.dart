import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:An_Smart_Farm_IOT/model/device_model.dart';
import 'package:An_Smart_Farm_IOT/pages/home/widgets/devices.dart';
import 'package:An_Smart_Farm_IOT/utils/string_to_color.dart';

import '../../constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String mode = 'automatic';
  List<DeviceModel> devices = [
    DeviceModel(
        name: 'Control Panel',
        isActive: true,
        color: "#33c0ba",
        icon: 'assets/svg/power-off-solid.svg'),
    DeviceModel(
        name: 'Smart water pump',
        isActive: true,
        color: "#ff5f5f",
        icon: 'assets/svg/water-solid.svg'),
    DeviceModel(
        name: 'Smart camera',
        isActive: true,
        color: "#7739ff",
        icon: 'assets/svg/camera-solid.svg'),
    DeviceModel(
        name: 'Smart Sensor',
        isActive: false,
        color: "#c9c306",
        icon: 'assets/svg/temperature-three-quarters-solid.svg'),
    DeviceModel(
        name: 'Smart Sound',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/speaker.svg'),
    DeviceModel(
        name: 'Smart Curtain',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/people-roof-solid.svg'),
    DeviceModel(
        name: 'Smart Fan',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/fan-solid.svg'),
    DeviceModel(
        name: 'Statistics',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/chart-column-solid.svg'),
    DeviceModel(
        name: 'About us',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/address-card-regular.svg'),
    DeviceModel(
        name: 'Settings',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/gear-solid.svg'),
  ];

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

  Future<void> fetchData() async {
    try {
      String hostname = await getMdnsHostname();
      final response = await http.get(Uri.parse('$hostname/data'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mode = data['automaticFan'] ? 'automatic' : 'manual';
          devices.firstWhere((d) => d.name == 'Smart Fan').isActive = data['automaticFan'];
          devices.firstWhere((d) => d.name == 'Smart Curtain').isActive = data['automaticCurtain'];
          devices.firstWhere((d) => d.name == 'Smart water pump').isActive = data['automaticPump'];
        });
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> changeMode(String device, String newMode) async {
    final endpoint = {
      'Smart Curtain': 'curtain',
      'Smart Fan': 'fan',
      'Smart water pump': 'pump',
    };

    final deviceEndpoint = endpoint[device];

    if (deviceEndpoint == null) {
      print('Device not supported for mode change');
      return;
    }

    String hostname = await getMdnsHostname();
    final url = '$hostname/$deviceEndpoint/mode/$newMode';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          mode = newMode;
          devices
              .firstWhere((d) => d.name == device)
              .isActive = (newMode == 'automatic');
        });
        print('$device changed to $newMode mode');
      } else {
        print('Failed to change mode for $device');
      }
    } catch (e) {
      print('Error changing mode for $device: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFfce2e1), Colors.white]),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      "Hi, Xuân An",
                      style: TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    CircleAvatar(
                        minRadius: 16,
                        backgroundImage: AssetImage("assets/images/user.webp"))
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "A total of 4 devices",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "Smart Farm",
                                    style: TextStyle(
                                        height: 1.1,
                                        fontSize: 17,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.more_horiz,
                                color: Colors.grey[300],
                                size: 30,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.only(top: 10, bottom: 20),
                              gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 4,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20),
                              itemCount: devices.length,
                              itemBuilder: (BuildContext ctx, index) {
                                bool isInteractive = devices[index].name != 'Statistics' &&
                                    devices[index].name != 'About us';

                                return Devices(
                                  name: devices[index].name,
                                  svg: devices[index].icon,
                                  color: devices[index].color.toColor(),
                                  isActive: devices[index].isActive,
                                  isInteractive: isInteractive,
                                  onChanged: isInteractive
                                      ? (val) {
                                    setState(() {
                                      devices[index].isActive = val;
                                    });
                                    final newMode = val ? 'automatic' : 'manual';
                                    changeMode(devices[index].name, newMode);
                                  }
                                      : null,
                                  mode: mode,
                                  changeMode: (newMode) {
                                    changeMode(devices[index].name, newMode);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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