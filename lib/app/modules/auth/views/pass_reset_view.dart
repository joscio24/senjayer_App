import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/app/services/loaderServices.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';

class PassResetView extends StatefulWidget {
  const PassResetView({super.key});

  @override
  PassResetViewState createState() => PassResetViewState();
}

class PassResetViewState extends State<PassResetView> {
  // final email_controller = TextEditingController();
  final confirm_pass = TextEditingController();
  final password_controller = TextEditingController();

  final Map<String, dynamic> data = Get.arguments as Map<String, dynamic>;

  bool isChecked = false;

  void _handleResetPassword(
    BuildContext context,
    String email,
    String password,
    String passwordConfirm,
    String token,
    String otp,
  ) async {
    ApiService apiService = ApiService();
    GetLoaderAction().showLoader();

    var result = await apiService.resetPassword(
      email,
      password,
      passwordConfirm,
      token,
      otp,
    );
    print("Your data is: $email");

    if (result["success"]) {
      GetLoaderAction().closeLoader();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mot de passe mis à jour avec succès"),
          backgroundColor: Colors.green,
        ),
      );

      // var token = result["data"]["token"];

      print(token);
      // Navigate to Dashboard

      Get.offAndToNamed('/pass_reset_success_otp');
      // Get.offAll(
      //   '/login',
      // );
    } else {
      GetLoaderAction().closeLoader();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur!, lors de l'envoi du mail de vérification."),
          backgroundColor: Colors.red,
        ),
      );
      print("Login failed: $result");
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
                child: Row(
                  children: [
                    Text(
                      'Créer un nouveau mot de passe',
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                      textAlign: TextAlign.start,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: "Mot de passe",
                      controller: password_controller,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      labelText: "Confirmer Mot de passe",
                      controller: confirm_pass,
                      isPassword: true,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isChecked, // Define isChecked as a state variable
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                      activeColor: appTheme.appViolet, // Change color as needed
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        children: [TextSpan(text: "Garder ma session active")],
                      ),
                    ),
                  ],
                ),
              ),

              // // // // invitation Button
              const SizedBox(height: 60),
              MainButtons(
                text: "Valider",
                onPressed: () {
                  _handleResetPassword(
                    context,
                    data["email"].toString(),
                    password_controller.text,
                    confirm_pass.text,
                    data["token"].toString(),
                    data["otp"].toString(),
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
