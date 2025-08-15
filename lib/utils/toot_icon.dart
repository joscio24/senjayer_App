import 'package:flutter/material.dart';

class TutorialLauncherButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TutorialLauncherButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: "tutorial_info_button",
      backgroundColor: const Color.fromARGB(18, 29, 29, 30),
      tooltip: "Aide",
      onPressed: onPressed,
      child: const Icon(Icons.info_outline, color: Color.fromARGB(197, 255, 255, 255)),
    );
  }
}
