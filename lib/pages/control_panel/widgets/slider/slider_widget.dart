import 'package:flutter/material.dart';
import 'package:An_Smart_Farm_IOT/pages/control_panel/widgets/slider/custom_arc.dart';
import 'package:An_Smart_Farm_IOT/utils/slider_utils.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SliderWidget extends StatelessWidget {
  final double progressVal;
  final Color color;
  final Function(double) onChange;
  final String unit;
  final double realValue; // New parameter to hold the real sensor value

  const SliderWidget({
    Key? key,
    required this.progressVal,
    required this.color,
    required this.onChange,
    required this.unit,
    required this.realValue, // Require real value parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kDiameter + 35,
      height: kDiameter + 35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: kDiameter + 35,
            height: kDiameter + 35,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          Center(
            child: CustomArc(
              color: color,
              diameter: kDiameter,
              sweepAngle: progressVal,
            ),
          ),
          Center(
            child: Container(
              width: kDiameter - 20,
              height: kDiameter - 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 15,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SleekCircularSlider(
                min: kMinDegree,
                max: kMaxDegree,
                initialValue: angleRange(progressVal, kMinDegree, kMaxDegree),
                appearance: CircularSliderAppearance(
                  spinnerMode: false,
                  startAngle: 180,
                  angleRange: 180,
                  size: kDiameter - 30,
                  customWidths: CustomSliderWidths(
                    trackWidth: 20,
                    shadowWidth: 0,
                    progressBarWidth: 1,
                    handlerSize: 5,
                  ),
                  customColors: CustomSliderColors(
                    hideShadow: true,
                    progressBarColor: Colors.transparent,
                    trackColor: Colors.transparent,
                    dotColor: color,
                  ),
                ),
                onChange: onChange,
                innerWidget: (percentage) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Display the actual sensor value instead of the percentage
                        Text(
                          '$realValue $unit', // Show real value with unit
                          style: const TextStyle(
                            height: 0,
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
