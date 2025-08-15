import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileController extends GetxController {
  var isLoading = true.obs;

  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  var gender = ''.obs;
  var profileImage = Rx<File?>(null);
  final int userId = 1; // Replace with actual user ID or load from session

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    try {
      final response = await http.get(
        Uri.parse('https://api.senjayer.com/api/v1/users/$userId'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final decoded = jsonDecode(response.body);
        final data = decoded['data']; // ✅ extract actual user object

        lastName.text = data['lastName'] ?? '';
        firstName.text = data['firstName'] ?? '';
        phone.text = data['phone'] ?? '';
        gender.value = data['gender'] ?? '';
        email.text = data['email'] ?? ''; // optional if you want to show it
      } else {
        Get.snackbar(
          "Erreur",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          ''
              //duration: Duration(seconds: 3),
              "Impossible de charger le profil.",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        //duration: Duration(seconds: 3),
        "Une erreur est survenue",
      );
    }

    isLoading.value = false;
  }

  Future<void> updateProfile() async {
    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      var uri = Uri.parse('https://api.senjayer.com/api/v1/users/$userId');

      var request = http.MultipartRequest('put', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['firstName'] = firstName.text;
      request.fields['lastName'] = lastName.text;
      request.fields['phone'] = phone.text;
      request.fields['gender'] = gender.value;

      // If an image is selected
      if (profileImage.value != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'image', // make sure this matches your backend field name
          profileImage.value!.path,
        );
        request.files.add(imageFile);
      }

      var response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar(
          "Succès",
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          //duration: Duration(seconds: 3),
          "Profil mis à jour",
        );
      } else {
        print("❌ Erreur: $resBody");
        Get.snackbar(
          "Erreur",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          //duration: Duration(seconds: 3),
          "Échec de la mise à jour",
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      Get.snackbar(
        "Erreur",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        //duration: Duration(seconds: 3),
        "Erreur réseau",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }
}
