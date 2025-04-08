import 'package:get/get.dart';
import 'package:senjayer/api/api_services.dart';

void _handleLogin(String Email, String Password) async {
  ApiService apiService = ApiService();
  var result = await apiService.login(Email, Password);
  // var result = await apiService.login("user@example.com", "password123");

  if (result["success"]) {
    print("Login successful: ${result["user"]}");
    Get.toNamed("/dashboard");
  } else {
    print("Login failed: ${result["message"]}");
  }
}

void _handleRegister() async {
  ApiService apiService = ApiService();
  // var result = await apiService.register(
    
  // );

  // if (result["success"]) {
  //   print("Registration successful!");
  // } else {
  //   print("Registration failed: ${result["message"]}");
  // }
}
