import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';

class WelcomePageView extends StatelessWidget {
  // final email_controller = TextEditingController();

  
  final Map<String, dynamic> user = Get.arguments;

   WelcomePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 120),
              // Logo
              Center(child: Column(children: [Image.asset('assets/logo.png')])),
              const SizedBox(height: 70),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bonjour, ",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  ),
                  TitleText_1(text: "${user['firstName'].toString()} ${user['lastName'].toString()}" ),
                ],
              ),

              SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Soyez la bienvenue sur",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    "Senjayer Priv8",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  // Senjayer Priv8
                ],
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Vous pouvez aussi voir les évenements à venir et ceux auxquels vous êtes invités.',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),

              // // // // invitation Button
              const SizedBox(height: 60),
              BlackButton(
                text: "Commencez",
                onPressed: () {
                  Get.toNamed('/dashboard');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}

Widget buildBottomNavigation() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Home Icon
        GestureDetector(
          onTap: () {
            Get.toNamed('/dashboard'); // Navigate to home screen
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(190, 225, 190, 231),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Image.asset("assets/home_icon.png", width: 40),
          ),
        ),

        // Create Event Button
        GestureDetector(
          onTap: () {
            // Handle event creation
            Get.toNamed('/dashboard');
          },
          child: Container(
            // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                // Plus Button with Border
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
                SizedBox(width: 10),
                // Text
                Text(
                  "Créer un event",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
