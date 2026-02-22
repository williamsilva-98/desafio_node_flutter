import '../models/user.dart';
import '../services/user_api_service.dart';

class UserRepository {
  UserRepository({UserApiService? userApiService})
      : _userApiService = userApiService ?? UserApiService();

  final UserApiService _userApiService;

  Future<List<User>> getUsers({String? name, String? email}) async {
    return _userApiService.getUsers(name: name, email: email);
  }

  Future<User> createUser({required String name, required String email}) async {
    return _userApiService.createUser(name: name, email: email);
  }
}
