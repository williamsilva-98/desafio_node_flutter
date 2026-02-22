import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/api_constants.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/user_api_service.dart';
import '../../features/users/view_models/users_form/user_form_cubit.dart';
import '../../features/users/view_models/users_list/user_list_cubit.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    return dio;
  });

  getIt.registerLazySingleton<UserApiService>(
    () => UserApiService(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(userApiService: getIt<UserApiService>()),
  );

  getIt.registerFactory<UserListCubit>(
    () => UserListCubit(userRepository: getIt<UserRepository>()),
  );
  
  getIt.registerFactory<UserFormCubit>(
    () => UserFormCubit(userRepository: getIt<UserRepository>()),
  );
}
