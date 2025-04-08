import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';

class PassResetOtpView extends StatefulWidget {
  const PassResetOtpView({super.key});

  @override
  _PassResetOtpViewState createState() => _PassResetOtpViewState();
}

class _PassResetOtpViewState extends State<PassResetOtpView> {
  final email_controller = TextEditingController();
  final phone_controller = TextEditingController();
  final password_controller = TextEditingController();

  final Map<String, dynamic> data = Get.arguments as Map<String, dynamic>;

  final int otpLength = 5;
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];
  String otpCode = "";

  @override
  void initState() {
    super.initState();
    controllers = List.generate(otpLength, (index) => TextEditingController());
    focusNodes = List.generate(otpLength, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to the next field if available
      if (index < otpLength - 1) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      }
    } else {
      // Move to the previous field on backspace
      if (index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      }
    }

    // Update the OTP value
    setState(() {
      otpCode = controllers.map((e) => e.text).join();
    });
  }

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
              const SizedBox(height: 100),

              Center(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 57, 5, 113),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),

                    SizedBox(width: 10),
                    MenuTexts(text: "Mot de passe oublié"),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Un code a été envoyé à l’adresse mail : \n ${data['email'].toString()}',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 80),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(otpLength, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color:
                                  appTheme
                                      .appViolet, // Change as per your theme
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color:
                                  appTheme
                                      .appViolet, // Change as per your theme
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        onChanged: (value) => _onChanged(value, index),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    // TextSpan(text: "Renvoyer le code dans"),
                    //
                    // TextSpan(
                    //   text: " 1:00",
                    //   style: TextStyle(
                    //     color: const Color.fromARGB(255, 45, 1, 53),
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   recognizer:
                    //       TapGestureRecognizer()
                    //         ..onTap = () {
                    //           // Get.toNamed('/forgot_pass');
                    //         },
                    // ),
                  ],
                ),
              ),

              // // // // invitation Button
              const SizedBox(height: 90),
              MainButtons(
                text: "Vérifier",
                onPressed: () {
                  Get.toNamed(
                    '/pass_reset',
                    arguments: {"email": data["email"], "otp": otpCode, "token":data["token"]},
                  );
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
