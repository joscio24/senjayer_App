import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkFirstTimeUser();
  }

  void _checkFirstTimeUser() async {
    await Future.delayed(Duration(seconds: 4)); // Simulate splash loading

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time')?? true;

    if (isFirstTime) {
      // Mark that user has seen onboarding
      await prefs.setBool('first_time', false);
      Get.offAllNamed(AppRoutes.ONBOARDING);
    } else {
      _checkUserLoginStatus();
    }
  }

  void _checkUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Retrieve stored token

    await Future.delayed(Duration(seconds: 3)); // Simulate loading

    if (token != null && token.isNotEmpty) {
      // User is logged in, navigate to dashboard
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else {
      // User is not logged in, navigate to login
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
