import 'package:flutter/material.dart';

class OptionWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  const OptionWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: selected ? Colors.blue : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: selected ? Colors.blue : Colors.grey)),
        ],
      ),
    );
  }
}