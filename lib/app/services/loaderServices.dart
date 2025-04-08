import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:senjayer/widgets/ThreeBarLoader.dart';

class GetLoaderAction {
  void showLoader() {
    Get.dialog(
      ThreeBarLoader(),
      barrierDismissible: false, // Prevents closing when tapping outside
    );
  }

  void closeLoader() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
