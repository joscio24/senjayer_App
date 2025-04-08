import 'package:get/get.dart';
import '../../../data/repository.dart';

class HomeController extends GetxController {
  var users = [].obs;
  final Repository _repository = Repository();

  @override
  void onInit() {
    // fetchUsers();
    super.onInit();
  }

  void fetchUsers() async {
    var response = await _repository.fetchUsers();
    users.value = response.data;
  }
}
