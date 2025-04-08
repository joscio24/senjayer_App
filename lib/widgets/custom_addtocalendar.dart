import 'package:flutter/material.dart';

class CustomAddtocalendar extends StatelessWidget {
  final String message;

  const CustomAddtocalendar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                children: [Image.asset('assets/success_add.png', width: 200)],
              ),
            ),
            // SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Function to show the dialog
void showCustomAddSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => CustomAddtocalendar(message: message),
  );
}
