import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainButtons extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Icon? icon;
  const MainButtons({super.key, required this.text, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon:  icon ?? null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 58, 0, 120),
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      label: Text(text, style: TextStyle(color: Colors.white)),

    );
  }
}

class BlackButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const BlackButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        minimumSize: Size(double.infinity, 70),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}
