import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/app/services/loaderServices.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_textfield.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  _SignupViewState createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  // Form Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  // Password Validation
  var passwordValid = false.obs;
  var containsNumber = false.obs;
  var containsLetter = false.obs;
  var minLength = false.obs;

  bool isLengthValid = false;
  bool hasNumber = false;
  bool hasLetter = false;
  bool passwordsMatch = false;

  // final RegisterController controller = Get.put(RegisterController());
  // void validatePassword(String password) {
  //   // print(password);
  //   minLength.value = password.length >= 6;
  //   containsNumber.value = password.contains(RegExp(r'[0-9]'));
  //   containsLetter.value = password.contains(RegExp(r'[A-Za-z]'));
  //   passwordValid.value =
  //       minLength.value && containsNumber.value && containsLetter.value;
  // }

  void validatePassword(String password) {
    setState(() {
      isLengthValid = password.length >= 6;
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    });
  }

  void validateMatchPassword() {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    setState(() {
      isLengthValid = password.length >= 6;
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
      passwordsMatch = password == confirmPassword;
    });
  }

  void _handleRegister(
    BuildContext context,
    String firstName,
    String lastName,
    String phoneNumber,
    String email,
    String password,
    String confirmPass,
  ) async {
    ApiService apiService = ApiService();
    GetLoaderAction().showLoader();

    var result = await apiService.register(
      firstName,
      lastName,
      phoneNumber,
      email,
      password,
      confirmPass,
    );
    // var result = await apiService.login("user@example.com", "password123");

    if (result["success"]) {
    GetLoaderAction().closeLoader();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Inscription réussi!}."),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Dashboard
      // Get.toNamed("/dashboard");
      Get.toNamed("/succes_reg");
    } else {
    GetLoaderAction().closeLoader();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur!, ${result["error_details"]["errors"]}."),
          backgroundColor: Colors.red,
        ),
      );
      print("Signup failed: ${result["error_details"]["errors"]}");
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
              TitleText_1(text: "Inscription"),
              const SizedBox(height: 20),
              // Email Input
              CustomTextField(
                labelText: 'Nom',
                controller: lastNameController,
                inputType: TextInputType.text,
                hintText: "Joe",
              ),

              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Prénom',
                controller: firstNameController,
                inputType: TextInputType.text,
                hintText: "Damie",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Email',
                controller: emailController,
                inputType: TextInputType.emailAddress,
                hintText: "votre@mail.com",
              ),
              const SizedBox(height: 16),

              // Password Input
              CustomTextField(
                labelText: 'Numéro de téléphone',
                controller: phoneController,
                inputType: TextInputType.phone,
                hintText: "+229 01 XX XX XX",
              ),

              const SizedBox(height: 16),

              CustomTextField(
                labelText: 'Mot de passe',
                controller: passwordController,
                hintText: "Votre mot de passe",
                isPassword: true,
                onChange: (value) {
                  // print(value);
                  validatePassword(value);
                  validateMatchPassword();
                },
              ),

              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Confirmez Mot de passe',
                controller: confirmPasswordController,
                hintText: "confirmez votre mot de passe",
                isPassword: true,
                onChange: (value) {
                  // validateMatchPassword();
                  validatePassword(value);
                  validateMatchPassword();
                },
              ),

              Row(
                children: [
                  Icon(
                    passwordsMatch ? Icons.check_circle : Icons.cancel,
                    color: passwordsMatch ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    passwordsMatch
                        ? 'Les mots de passe correspondent'
                        : 'Les mots de passe ne correspondent pas',
                    style: TextStyle(
                      color: passwordsMatch ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Password Requirements
              Center(child: Text('Votre mot de passe doit contenir')),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isLengthValid ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text('Au minimum 6 caractères'),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: hasLetter ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text('Contenir un caractère ASCII et un chiffre'),
                ],
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(text: "En m’inscrivant, j’accepte les "),
                    TextSpan(
                      text: "conditions",
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                      // recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                    ),
                    TextSpan(text: " et "),
                    TextSpan(
                      text: "politique de service.",
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                      // recognizer: TapGestureRecognizer()..onTap = onPolicyTap,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Signup Button
              MainButtons(
                text: "S'inscrire",
                onPressed: () {
                  // run signup function here to let user in before going to succes page
                  _handleRegister(
                    context,
                    firstNameController.text,
                    lastNameController.text,
                    phoneController.text,
                    emailController.text,
                    passwordController.text,
                    confirmPasswordController.text,
                  );
                  // Get.toNamed('/succes_reg');
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
                  Text('Vous avez déjà un compte ? '),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/login');
                    },
                    child: Text(
                      'Connectez-vous',
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
