import 'package:app/app.dart';
import 'package:app/core/di/injection.dart';
import 'package:app/data/repositories/user_repository.dart';
import 'package:app/features/users/view_models/users_form/user_form_cubit.dart';
import 'package:app/features/users/view_models/users_list/user_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(null as String?);
  });

  setUp(() {
    mockRepository = MockUserRepository();
    getIt.reset();
    getIt.registerSingleton<UserRepository>(mockRepository);
    getIt.registerFactory<UserListCubit>(
      () => UserListCubit(userRepository: getIt<UserRepository>()),
    );
    getIt.registerFactory<UserFormCubit>(
      () => UserFormCubit(userRepository: getIt<UserRepository>()),
    );
  });

  testWidgets('App starts with Users title in the bar', (WidgetTester tester) async {
    when(() => mockRepository.getUsers(name: any(named: 'name'), email: any(named: 'email')))
        .thenAnswer((_) async => []);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Usuários'), findsOneWidget);
  });
}
