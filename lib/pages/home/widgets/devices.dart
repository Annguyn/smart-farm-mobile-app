import 'package:An_Smart_Farm_IOT/pages/about_us/about_us_page.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/control_panel_page.dart';
import 'package:An_Smart_Farm_IOT/pages/camera_control/camera_control_page.dart';

import '../../control_panel/statistics_page.dart';

class Devices extends StatelessWidget {
  final String name;
  final String svg;
  final Color color;
  final bool isActive;
  final Function(bool)? onChanged;
  final bool isInteractive;
  final String mode; // Add mode property
  final Function(String)? changeMode; // Add changeMode callback

  const Devices({
    Key? key,
    required this.name,
    required this.svg,
    required this.color,
    required this.onChanged,
    required this.isActive,
    required this.isInteractive,
    required this.mode, // Add mode property
    required this.changeMode, // Add changeMode callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 600),
      closedElevation: 0,
      openElevation: 0,
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      openBuilder: (BuildContext context, VoidCallback _) {
        if (name == 'Smart camera') {
          return CameraControlPage();
        } else if (name == 'Statistics') {
          return StatisticsPage();
        } else if (name == 'About us') {
          return AboutUsPage();
        } else {
          return ControlPanelPage(tag: name);
        }
      },
      tappable: true,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 0.6,
              ),
              color: isActive ? color : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        svg,
                        color: isActive ? Colors.white : Colors.black,
                        height: 30,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 65,
                        child: Text(
                          name,
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 14,
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isInteractive)
                    Transform.scale(
                      alignment: Alignment.center,
                      scaleY: 0.8,
                      scaleX: 0.85,
                      child: CupertinoSwitch(
                        onChanged: (val) {
                          if (name == 'Smart water pump') {
                            String newMode = mode == "automatic" ? "manual" : "automatic";
                            changeMode!(newMode);
                          }
                          onChanged!(val);
                        },
                        value: isActive,
                        activeColor: isActive ? Colors.white.withOpacity(0.4) : Colors.black,
                        trackColor: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}