import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';

class SuccessRegView extends StatelessWidget {
  final email_controller = TextEditingController();
  final phone_controller = TextEditingController();
  final password_controller = TextEditingController();

  SuccessRegView({super.key});

  // final Map<String, dynamic> user = Get.arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              // Logo
              Center(child: Column(children: [Image.asset('assets/logo.png')])),
              const SizedBox(height: 100),

              Center(
                child: Column(
                  children: [
                    Image.asset('assets/success_check.png', width: 200),
                  ],
                ),
              ),
              const SizedBox(height: 80),

              TitleText_2(text: "Votre compte \n a été crée avec succès."),
              // invitation Button
              const SizedBox(height: 20),
              BlackButton(
                text: "Vos Invitations",
                onPressed: () {
                  Get.toNamed("/login");
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
