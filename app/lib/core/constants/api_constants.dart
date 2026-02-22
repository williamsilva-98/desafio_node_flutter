class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String usersPath = '/users';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
