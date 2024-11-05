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
        name: 'Statistics',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/speaker.svg'),
    DeviceModel(
        name: 'About us',
        isActive: false,
        color: "#c207db",
        icon: 'assets/svg/speaker.svg'),
  ];

  Future<void> changeMode(String newMode) async {
    try {
      final response = await http.post(
        Uri.parse('http://$flaskIp/mode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mode': newMode}),
      );

      if (response.statusCode == 200) {
        setState(() {
          mode = newMode;
        });
        print('Mode changed to $newMode');
      } else {
        print('Failed to change mode');
      }
    } catch (e) {
      print('Error changing mode: $e');
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
                                  // Determine if the device is interactive
                                  bool isInteractive = devices[index].name != 'Statistics' &&
                                      devices[index].name != 'About us';

                                  return Devices(
                                    name: devices[index].name,
                                    svg: devices[index].icon,
                                    color: devices[index].color.toColor(),
                                    isActive: devices[index].isActive,
                                    isInteractive: isInteractive, // New parameter
                                    onChanged: isInteractive
                                        ? (val) {
                                      setState(() {
                                        devices[index].isActive =
                                        !devices[index].isActive;
                                      });
                                    }
                                        : null, // Disable the callback for non-interactive devices
                                    mode: mode, // Pass mode property
                                    changeMode: changeMode, // Pass changeMode callback
                                  );
                                }),
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