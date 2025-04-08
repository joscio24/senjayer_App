import 'package:flutter/material.dart';

class CustomSuccessDialog extends StatelessWidget {
  final String message;

  const CustomSuccessDialog({super.key, required this.message});

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
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  children: [
                    Image.asset('assets/success_check.png', width: 150),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
void showCustomSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => CustomSuccessDialog(message: message),
  );
}
