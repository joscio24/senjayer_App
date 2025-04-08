import 'package:flutter/material.dart';

class CustomRejectDialog extends StatelessWidget {
  final String message;

  const CustomRejectDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(126, 250, 123, 123),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  children: [Image.asset('assets/error_check.png', width: 150)],
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // OutlinedButton(
            //   onPressed: () => Navigator.pop(context),
            //   style: OutlinedButton.styleFrom(
            //     side: BorderSide(color: Colors.green),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   child: Text("OK", style: TextStyle(color: Colors.green)),
            // ),
          ],
        ),
      ),
    );
  }
}

// Function to show the dialog
void showCustomErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => CustomRejectDialog(message: message),
  );
}
