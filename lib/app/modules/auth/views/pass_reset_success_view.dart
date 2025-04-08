import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';

class PassResetSuccessView extends StatelessWidget {
  const PassResetSuccessView({super.key});

  // final email_controller = TextEditingController();

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
              Center(
                child: Column(children: [Image.asset('assets/Onboarding.png')]),
              ),
              const SizedBox(height: 40),

              TitleText_1(text: "Mot de passe réinitialisé"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Bon retour !',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),

              // // // // invitation Button
              const SizedBox(height: 60),
              MainButtons(
                text: "Retour à l'accueil",
                onPressed: () {
                  Get.toNamed('/login');
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
