import 'package:dio/dio.dart';
import 'api_routes.dart';

class Repository {
  final Dio _dio = Dio();

  Future<Response> fetchUsers() async {
    return await _dio.get(ApiRoutes.getUsers);
  }
}
