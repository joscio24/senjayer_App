import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

// import 'package:get/get.dart';
import 'package:senjayer/api/api_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = "https://yourapi.com"; // Change this to your API
  // static const String loginUrl = "$baseUrl/auth/login";
  // static const String registerUrl = "$baseUrl/auth/register";

  final Dio _dio = Dio();
  // login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      Response response = await _dio.post(
        ApiRoutes.loginUrl,
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveUserData(data["access_token"], data["user"]);
        return {
          "success": true,
          "message": "Login successful",
          "user": data["user"],
        };
      } else {
        print("error $response");
        return {
          "success": false,
          "message": response.data["message"],
          "errors": response,
        };
      }
    } catch (e) {
      // Handle DioException specifically
      if (e is DioException) {
        // Capture the error response if available
        if (e.response != null) {
          // Log response data for debugging
          print("Dio Exception Response: ${e.response?.data}");

          // Return the response data along with error status
          return {
            "success": false,
            "message":
                "login failed with status code ${e.response?.statusCode}",
            "error_details":
                e.response?.data ?? "No additional error details available",
          };
        } else {
          // If no response is available (e.g., connection error), log that
          return {
            "success": false,
            "message": "Registration failed with an error: $e",
            "error_details": e.toString(),
          };
        }
      } else {
        // Fallback for any other types of errors
        return {
          "success": false,
          "message": "Registration failed with an unknown error: $e",
        };
      }
    }
  }

  // forgot password
  // Forgot Password Request (Takes only email)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      Response response = await _dio.post(
        ApiRoutes.forgotPassword,
        data: {"email": email},
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Password reset link sent to email",
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Something went wrong",
        };
      }
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // Reset Password Request (Takes password and confirmPassword)
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
    String confirmPassword,
    String token,
    String otp,
  ) async {
    try {
      if (password != confirmPassword) {
        return {"success": false, "message": "Passwords do not match"};
      }

      Response response = await _dio.post(
        ApiRoutes.resetPassword,
        data: {
          "password": password,
          "password_confirmation": confirmPassword,
          "email": email,
          "reset_code": otp,
          "token": token,
        },
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Password reset successful"};
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Something went wrong",
        };
      }
    } catch (e) {
      return _handleDioError(e);
    }
  }

  // Handles Dio Errors and Network Failures
  Map<String, dynamic> _handleDioError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        return {
          "success": false,
          "message": e.response?.data["message"] ?? "Request failed",
          "error_details": e.response?.data,
        };
      } else {
        return {"success": false, "message": "Network error: ${e.message}"};
      }
    }
    return {"success": false, "message": "Unexpected error: $e"};
  }

  // reset password

  // register
  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String phone,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      // Print data before sending
      print(
        'Data sent: $firstName, $lastName, $phone, $email, $password, $passwordConfirmation',
      );

      // Send the POST request
      Response response = await _dio.post(
        ApiRoutes.registerUrl,
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "phone": phone,
          "email": email,
          "role_id": "2", // Add other fields if necessary
          "password": password,
          "password_confirmation": passwordConfirmation,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          }, // Ensure the content type is set to application/json
        ),
      );

      // Log response status and body for debugging
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");

      // Check the status code and return appropriate result
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Registration successful",
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message":
              "Error ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}",
          "data": response.data,
        };
      }
    } catch (e) {
      // Handle DioException specifically
      if (e is DioException) {
        // Capture the error response if available
        if (e.response != null) {
          // Log response data for debugging
          print("Dio Exception Response: ${e.response?.data}");

          // Return the response data along with error status
          return {
            "success": false,
            "message":
                "Registration failed with status code ${e.response?.statusCode}",
            "error_details":
                e.response?.data ?? "No additional error details available",
          };
        } else {
          // If no response is available (e.g., connection error), log that
          return {
            "success": false,
            "message": "Registration failed with an error: $e",
            "error_details": e.toString(),
          };
        }
      } else {
        // Fallback for any other types of errors
        return {
          "success": false,
          "message": "Registration failed with an unknown error: $e",
        };
      }
    }
  }

  // save user data
  Future<void> _saveUserData(String token, Map<String, dynamic> user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("user", jsonEncode(user));
  }

  // get userdate
  Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("user");
    String? token = prefs.getString("token");

    if (userData != null && token != null) {
      return {
        "token": token,
        "user": jsonDecode(userData),
      }; // Decode only if stored as JSON
    }
    return null;
  }

  // getinivted event
  Future<Map<String, dynamic>?> getEventsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    // print("Fetching events from: ${ApiRoutes.getEventsDetails}");

    try {
      Response response = await _dio.get(
        ApiRoutes.getEventsDetails,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // print("API Response: ${response.data}");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Events retrieved successfully",
          "events": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Unknown error",
        };
      }
    } catch (e) {
      print("Error: $e"); // Debugging error
      return {"success": false, "message": "Failed to retrieve events: $e"};
    }
  }

  // get user events
  Future<Map<String, dynamic>?> getUsersEventsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    // print("Fetching events from: ${ApiRoutes.getEventsDetails}");

    try {
      Response response = await _dio.get(
        ApiRoutes.getEvents,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // print("API Response: ${response.data}");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Events retrieved successfully",
          "events": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Unknown error",
        };
      }
    } catch (e) {
      print("Error: $e"); // Debugging error
      return {"success": false, "message": "Failed to retrieve events: $e"};
    }
  }

  // get categories
  Future<Map<String, dynamic>?> getEventsCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    // print("Fetching events from: ${ApiRoutes.getEventsDetails}");

    try {
      Response response = await _dio.get(
        ApiRoutes.getCategories,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // print("API Response: ${response.data}");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Events retrieved successfully",
          "categories": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Unknown error",
        };
      }
    } catch (e) {
      print("Error: $e"); // Debugging error
      return {"success": false, "message": "Failed to retrieve events: $e"};
    }
  }

  Future<Map<String, dynamic>?> getUserProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    // print("Fetching events from: ${ApiRoutes.getEventsDetails}");

    try {
      Response response = await _dio.get(
        ApiRoutes.getUserProfile,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // print("API Response: ${response.data}");

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Events retrieved successfully",
          "categories": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Unknown error",
        };
      }
    } catch (e) {
      print("Error: $e"); // Debugging error
      return {"success": false, "message": "Failed to retrieve events: $e"};
    }
  }

  Future<Map<String, dynamic>?> createEvent({
    required String name,
    required String description,
    required String eventAddress,
    required double addressLongitude,
    required double addressLatitude,
    required File imageUrl,
    required String categoryId,
    required int private,
    required int userId,
    required String startDate,
    required String endDate,
    required int nbPlace,
    required String startTicket,
    required String endTicket,
    required int status,
    required List<String> guest,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      String fileName = imageUrl.path.split('/').last;

      FormData formData = FormData();

      // Ajouter les champs classiques
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('description', description),
        MapEntry('event_address', eventAddress),
        MapEntry('address_longitude', addressLongitude.toString()),
        MapEntry('address_latitude', addressLatitude.toString()),
        MapEntry('category_id', categoryId),
        MapEntry('private', private.toString()),
        MapEntry('user_id', userId.toString()),
        MapEntry('start_date', startDate),
        MapEntry('end_date', endDate),
        MapEntry('nb_place', nbPlace.toString()),
        MapEntry('start_ticket', startTicket),
        MapEntry('end_ticket', endTicket),
        MapEntry('status', status.toString()),
      ]);

      // Ajouter le fichier image
      formData.files.add(
        MapEntry(
          'image_url',
          await MultipartFile.fromFile(imageUrl.path, filename: fileName),
        ),
      );

      // Ajouter les invités (array -> guest[0], guest[1], etc.)
      for (int i = 0; i < guest.length; i++) {
        formData.fields.add(MapEntry('guest[$i]', guest[i]));
      }

      // Envoyer la requête
      Response response = await _dio.post(
        ApiRoutes.createEvent,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "Event created successfully",
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message":
              "Error ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}",
          "data": response.data,
        };
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        return {
          "success": false,
          "message":
              "Event creation failed with status code ${e.response?.statusCode}",
          "error_details": e.response?.data ?? "No additional details",
        };
      } else {
        return {"success": false, "message": "An unknown error occurred: $e"};
      }
    }
  }

  // create events
  // Future<Map<String, dynamic>?> createEvent({
  //   required String name,
  //   required String description,
  //   required String eventAddress,
  //   required double addressLongitude,
  //   required double addressLatitude,
  //   required File imageUrl,
  //   required String categoryId, // If your backend expects int, change to int
  //   required int private,
  //   required int userId,
  //   required String startDate,
  //   required String endDate,
  //   required int nbPlace,
  //   required String startTicket,
  //   required String endTicket,
  //   required int status,
  //   required List<String> guest,
  // }) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString("token");

  //   try {
  //     print('Creating Event with data: $name, $description, $eventAddress');
  //     print("📦 Preparing to send event:");
  //     print("🔑 Token: $token");
  //     print("📝 Name: $name");
  //     print("📍 Address: $eventAddress ($addressLatitude, $addressLongitude)");
  //     print("🖼️ Image: ${imageUrl.path}");
  //     print("📅 Dates: $startDate to $endDate");
  //     print("🎫 Tickets: $startTicket to $endTicket");
  //     print("👥 Guests: $guest");
  //     print(
  //       "🔢 Category ID: $categoryId | Private: $private | Status: $status",
  //     );

  //     print("File exists: ${await imageUrl.exists()}");
  //     print("File path: ${imageUrl.path}");
  //     print("File size: ${await imageUrl.length()} bytes");

  //     String fileName = imageUrl.path.split('/').last;
  //     MultipartFile multipartFile = await MultipartFile.fromFile(imageUrl.path);

  //     FormData formData = FormData.fromMap({
  //       "name": name,
  //       "description": description,
  //       "event_address": eventAddress,
  //       "address_longitude": addressLongitude,
  //       "address_latitude": addressLatitude,
  //       "category_id":
  //           categoryId, // or int.parse(categoryId) if backend needs int
  //       "image_url": multipartFile,
  //       "private": private,
  //       "user_id": userId,
  //       "start_date": startDate,
  //       "end_date": endDate,
  //       "nb_place": nbPlace,
  //       "start_ticket": startTicket,
  //       "end_ticket": endTicket,
  //       "status": status,
  //       "guest": jsonEncode(guest),
  //     });

  //     Response response = await _dio.post(
  //       ApiRoutes.createEvent,

  //       options: Options(
  //         headers: {
  //           "Content-Type": "multipart/form-data",
  //           'Authorization': 'Bearer $token',
  //         },
  //       ),
  //       data: formData,
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return {
  //         "success": true,
  //         "message": "Event created successfully",
  //         "data": response.data,
  //       };
  //     } else {
  //       return {
  //         "success": false,
  //         "message":
  //             "Error ${response.statusCode}: ${response.data['message'] ?? 'Unknown error'}",
  //         "data": response.data,
  //       };
  //     }
  //   } catch (e) {
  //     if (e is DioException) {
  //       if (e.response != null) {
  //         print("Dio Exception Response: ${e.response?.data}");
  //         return {
  //           "success": false,
  //           "message":
  //               "Event creation failed with status code ${e.response?.statusCode}",
  //           "error_details": e.response?.data ?? "No additional details",
  //         };
  //       } else {
  //         return {
  //           "success": false,
  //           "message": "Event creation failed: $e",
  //           "error_details": e.toString(),
  //         };
  //       }
  //     } else {
  //       return {"success": false, "message": "An unknown error occurred: $e"};
  //     }
  //   }
  // }

  // get packages
  Future<Map<String, dynamic>?> getPackages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      Response response = await _dio.get(
        ApiRoutes.getPackages,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Packages retrieved successfully",
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Unknown error",
        };
      }
    } catch (e) {
      print("Error: $e");
      return {"success": false, "message": "Failed to retrieve packages: $e"};
    }
  }

  Future<Map<String, dynamic>?> getPackagesById(packageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      Response response = await _dio.get(
        ApiRoutes.getPackages,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Packages retrieved successfully",
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Unknown error",
        };
      }
    } catch (e) {
      print("Error: $e");
      return {"success": false, "message": "Failed to retrieve packages: $e"};
    }
  }

  // subscription
  Future<Map<String, dynamic>?> subscribeToPackage({
    required int userId,
    required int packageId,
    required int eventLimit,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      Response response = await _dio.post(
        ApiRoutes.subscribtions,
        data: {
          "user_id": userId,
          "package_id": packageId,
          "event_limit": eventLimit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print("✅ Response status: ${response.statusCode}");
      print("✅ Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": response.data["message"] ?? "Subscription successful",
          "data": response.data["data"] ?? response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Subscription failed",
          "data": response.data,
        };
      }
    } catch (e) {
      if (e is DioError) {
        print("❌ DioError: ${e.response?.data["message"]}");
        return {
          "success": false,
          "message": e.response?.data["message"] ?? "Dio error occurred",
          "data": e.response?.data,
        };
      }

      print("❌ Unexpected error: $e");
      return {"success": false, "message": "Unexpected error: $e"};
    }
  }

  // create transaction
  Future<Map<String, dynamic>?> createTransaction({
    required int userId,
    required String firstName,
    required String lastName,
    required String phone,
    required double amount,
    required String operator,
    required List<dynamic> items,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final requestData = {
      "id": userId,
      "user_id": userId,
      "firstName": firstName,
      "lastName": lastName,
      "phone": phone,
      "amount": amount,
      "price": amount,
      "operator": operator,
      "items": items,
    };

    print("📦 Submitting transaction data: $requestData");

    try {
      Response response = await _dio.post(
        ApiRoutes.transactions,
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "Transaction created successfully",
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Transaction failed",
        };
      }
    } catch (e) {
      if (e is DioError) {
        print("❌ DioError: ${e.response?.data}");
        return {
          "success": false,
          "message": e.response?.data["message"] ?? "Dio error occurred",
          "data": e.response?.data,
        };
      }

      print("❌ Unexpected error: $e");
      return {"success": false, "message": "Unexpected error: $e"};
    }
  }

  // get transaction by refernce
  Future<Map<String, dynamic>?> getTransactionByReference({
    required String referenceId,
    required String client,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      final String url = "${ApiRoutes.transactions}/$referenceId/$client";

      Response response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      ); 

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Transaction details retrieved",
          "data": response.data,
        };
      } else {
        return {
          "success": false,
          "message": response.data["message"] ?? "Transaction lookup failed",
        };
      }
    } catch (e) {
      print("Error: $e");
      return {"success": false, "message": "Failed to get transaction: $e"};
    }
  }

  Future<Map<String, dynamic>?> postSubscription(
    Map<String, dynamic> payload,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final url = ApiRoutes.transactions;
    final response = await _dio.post(
      url,
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "success": true,
        "message": "Subscription successful",
        "data": response.data,
      };
    } else {
      return {
        "success": false,
        "message": response.data["message"] ?? "Subscription failed",
      };
    }
  }

  // Future<void> subscribeAfterTransaction({
  //   required int userId,
  //   required int packageId,
  // }) async {
  //   // 1. Récupérer le package pour obtenir le `event_limit`
  //   final package = await getPackageById(packageId);
  //   final eventLimit = package["event_limit"];

  //   // 2. Faire la souscription
  //   final result = await subscribeToPackage(
  //     userId: userId,
  //     packageId: packageId,
  //     eventLimit: eventLimit,
  //   );

  //   if (result?["success"] == true) {
  //     // Afficher succès ou rediriger
  //   }
  // }
}
