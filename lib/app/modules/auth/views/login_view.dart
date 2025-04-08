import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/app/services/loaderServices.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';
import 'package:senjayer/app/modules/auth/controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  final email_controller = TextEditingController();
  final phone_controller = TextEditingController();
  final password_controller = TextEditingController();

  LoginView({super.key});

  void _handleLogin(BuildContext context, String Email, String Password) async {
    ApiService apiService = ApiService();

    if (Email.isEmpty || Password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez remplir les champs"),
          backgroundColor: const Color.fromARGB(255, 216, 132, 6),
        ),
      );
    } else {
      GetLoaderAction().showLoader();
      var result = await apiService.login(Email, Password);
      // var result = await apiService.login("user@example.com", "password123");

      if (result["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Connexion réussi!, ${result["user"]["firstName"]} ${result["user"]["lastName"]}.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Dashboard
        // Get.toNamed("/dashboard");
        Get.toNamed("/dashboard");
      } else {
        GetLoaderAction().closeLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur!, ${result["error_details"]["errors"]["message"]}.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        print("Login failed: ${result["error_details"]["errors"]["message"]}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Logo
              Center(child: Column(children: [Image.asset('assets/logo.png')])),
              const SizedBox(height: 80),
              TitleText_1(text: "Connexion"),
              const SizedBox(height: 20),

              // Email Input
              CustomTextField(
                labelText: 'Email',
                controller: email_controller,
                inputType: TextInputType.emailAddress,
                hintText: "votre@mail.com",
              ),

              const SizedBox(height: 16),

              CustomTextField(
                labelText: 'Mot de passe',
                controller: password_controller,
                isPassword: true,
                hintText: "votre mot de passe",
              ),

              const SizedBox(height: 46),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(text: "Mot de passe oublié ?"),

                    TextSpan(
                      text: " Cliquez ici",
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              if (email_controller.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Veuillez entrer le mail"),
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      216,
                                      132,
                                      6,
                                    ),
                                  ),
                                );
                              } else {
                                Get.toNamed(
                                  '/forgot_pass',
                                  arguments: {"email": email_controller.text},
                                );
                              }
                            },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // Signup Button
              MainButtons(
                text: "Se connecter",
                onPressed: () {
                  _handleLogin(
                    context,
                    email_controller.text,
                    password_controller.text,
                  );
                },
              ),
              const SizedBox(height: 20),
              Text('ou poursuivre avec'),
              const SizedBox(height: 16),
              // Social Media Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => {},
                    child: Image.asset(
                      "assets/facebook.png",
                      width: 70,
                      height: 70,
                    ),
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => {},
                    child: Image.asset(
                      "assets/twitter.png",
                      width: 60,
                      height: 70,
                    ),
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => {},
                    child: Image.asset(
                      "assets/google.png",
                      width: 60,
                      height: 60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vous n\'avez pas un compte ? '),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/signup');
                    },
                    child: Text(
                      'Inscrivez-vous',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
