import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/user.dart';

class UserApiService {
  final Dio _dio;

  static final _baseOptions = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  UserApiService({Dio? dio}) : _dio = dio ?? Dio(_baseOptions);

  Future<User> createUser({required String name, required String email}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.usersPath,
        data: {'name': name, 'email': email},
      );

      final data = response.data;
      
      if (data == null) throw Exception('Resposta vazia');
      
      return User.fromJson(data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<List<User>> getUsers({String? name, String? email}) async {
    final queryParams = <String, dynamic>{};

    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (email != null && email.isNotEmpty) queryParams['email'] = email;

    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.usersPath,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final list = response.data;
      
      if (list == null) return [];
      
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  static ApiException _toApiException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    
    String message = 'Erro ao comunicar com o servidor';
    
    if (data is Map<String, dynamic> && data['message'] != null) {
      message = data['message'] as String;
    } else if (e.message != null) {
      message = e.message!;
    }
    
    return ApiException(message, statusCode);
  }
}
