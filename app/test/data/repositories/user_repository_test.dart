import 'package:app/core/errors/api_exception.dart';
import 'package:app/data/models/user.dart';
import 'package:app/data/repositories/user_repository.dart';
import 'package:app/data/services/user_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserApiService extends Mock implements UserApiService {}

void main() {
  late MockUserApiService mockService;
  late UserRepository repository;

  setUp(() {
    mockService = MockUserApiService();
    repository = UserRepository(userApiService: mockService);
  });

  group('UserRepository.getUsers', () {
    test('delegates to service and returns list', () async {
      const users = [
        User(id: 1, name: 'João', email: 'joao@email.com'),
      ];
      when(() => mockService.getUsers(name: any(named: 'name'), email: any(named: 'email')))
          .thenAnswer((_) async => users);

      final result = await repository.getUsers();
      expect(result, users);
      verify(() => mockService.getUsers(name: null, email: null)).called(1);
    });

    test('passes filters to the service', () async {
      when(() => mockService.getUsers(name: any(named: 'name'), email: any(named: 'email')))
          .thenAnswer((_) async => []);

      await repository.getUsers(name: 'João', email: 'joao@');

      verify(() => mockService.getUsers(name: 'João', email: 'joao@')).called(1);
    });
  });

  group('UserRepository.createUser', () {
    test('delegates to service and returns User', () async {
      const user = User(id: 1, name: 'Maria', email: 'maria@email.com');
      when(() => mockService.createUser(name: any(named: 'name'), email: any(named: 'email')))
          .thenAnswer((_) async => user);

      final result = await repository.createUser(
        name: 'Maria',
        email: 'maria@email.com',
      );
      expect(result, user);
      verify(() => mockService.createUser(name: 'Maria', email: 'maria@email.com')).called(1);
    });

    test('propagates ApiException from service', () async {
      when(() => mockService.createUser(name: any(named: 'name'), email: any(named: 'email')))
          .thenThrow(const ApiException('E-mail já cadastrado', 409));

      expect(
        () => repository.createUser(name: 'X', email: 'x@x.com'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
