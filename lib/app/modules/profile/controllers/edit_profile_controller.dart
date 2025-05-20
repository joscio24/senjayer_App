import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../api/api_routes.dart';

class EditProfileController extends GetxController {
  late final dio.Dio _dio;

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final gender = 'M'.obs;

  final isLoading = false.obs;
  final profileImage = Rx<File?>(null);
  int userId = 0;

  EditProfileController() {
    _dio = dio.Dio();
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    await _getUserId();
    if (userId != 0) {
      fetchProfile();
    }
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString("user");

    if (userString != null) {
      Map<String, dynamic> userData = jsonDecode(userString);
      userId = userData["id"] ?? 0;
    } else {
      userId = 0;
    }
  }

  Future<Map<String, dynamic>?> getUserProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      dio.Response response = await _dio.get(
        "${ApiRoutes.getUserProfile}/$userId",
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Profil récupéré avec succès",
          "categories": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Erreur inconnue",
        };
      }
    } catch (e) {
      print("Erreur API: $e");
      return {"success": false, "message": "Erreur: $e"};
    }
  }

  void fetchProfile() async {
    isLoading.value = true;
    var profileResponse = await getUserProfileData();

    if (profileResponse == null || !(profileResponse["success"] as bool)) {
      Get.snackbar("Erreur", profileResponse?["message"] ?? "Chargement impossible");
      isLoading.value = false;
      return;
    }

    var data = profileResponse["categories"];

    firstName.text = data['firstName'] ?? '';
    lastName.text = data['lastName'] ?? '';
    email.text = data['email'] ?? '';
    phone.text = data['phone'] ?? '';
    gender.value = data['gender'] ?? 'M';

    if (data['image_url'] != null && data['image_url'].toString().isNotEmpty) {
      profileImage.value = File(data['image_url']); // Optionnel selon ton usage
    }

    isLoading.value = false;
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

  void updateProfile() async {
    try {
      isLoading.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final payload = dio.FormData.fromMap({
        "firstName": firstName.text,
        "lastName": lastName.text,
        "email": email.text,
        "phone": phone.text,
        "gender": gender.value,
        if (profileImage.value != null)
          "profile_image": await dio.MultipartFile.fromFile(
            profileImage.value!.path,
            filename: profileImage.value!.path.split("/").last,
          ),
      });

      dio.Response response = await _dio.put(
        "${ApiRoutes.getUserProfile}/$userId",
        data: payload,
        options: dio.Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Succès", "Profil mis à jour !");
      } else {
        Get.snackbar("Erreur", "Échec de la mise à jour");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Erreur: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
