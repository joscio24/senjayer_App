import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  var currentIndex = 0.obs;


  void updateIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    Get.offAllNamed(AppRoutes.LOGIN); // Navigate to dashboard after onboarding
  }

  // Future<void> checkIfFirstTimeUser() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool isFirstTime = prefs.getBool('first_time') ?? true;

  //   if (!isFirstTime) {
  //     Get.offAllNamed(AppRoutes.ONBOARDING); // Skip onboarding if already completed
  //   }
  // }
}
