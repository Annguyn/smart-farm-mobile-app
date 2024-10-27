import 'package:flutter/material.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/control_panel_page.dart';
import 'package:An_Smart_Farm_IOT/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farm',
      theme: ThemeData(
          fontFamily: "Poppins",
          sliderTheme: const SliderThemeData(
            trackShape: RectangularSliderTrackShape(),
            trackHeight: 2.5,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 15.0),
          )),
      home: const HomePage(),
    );
  }
}
