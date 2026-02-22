import 'package:app/data/models/user.dart';
import 'package:app/features/users/view_models/users_list/user_list_cubit.dart';
import 'package:app/data/repositories/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
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
  });

  group('UserListCubit', () {
    blocTest<UserListCubit, UserListState>(
      'emits [loading, loaded] when loadUsers returns data',
      build: () {
        when(() => mockRepository.getUsers(name: any(named: 'name'), email: any(named: 'email')))
            .thenAnswer((_) async => [
                  const User(id: 1, name: 'João', email: 'joao@email.com'),
                ]);
        return UserListCubit(userRepository: mockRepository);
      },
      act: (cubit) => cubit.loadUsers(),
      expect: () => [
        const UserListState.loading(),
        UserListState.loaded([
          const User(id: 1, name: 'João', email: 'joao@email.com'),
        ]),
      ],
    );

    blocTest<UserListCubit, UserListState>(
      'emits [loading, failure] when loadUsers throws',
      build: () {
        when(() => mockRepository.getUsers(name: null, email: null))
            .thenAnswer((_) async => throw Exception('Erro de rede'));
        return UserListCubit(userRepository: mockRepository);
      },
      act: (cubit) => cubit.loadUsers(),
      expect: () => [
        const UserListState.loading(),
        isA<UserListState>().having(
          (s) => s.status,
          'status',
          UserListStatus.failure,
        ),
      ],
    );

    blocTest<UserListCubit, UserListState>(
      'passes name and email to getUsers when filtering',
      build: () {
        when(() => mockRepository.getUsers(name: any(named: 'name'), email: any(named: 'email')))
            .thenAnswer((_) async => []);
        return UserListCubit(userRepository: mockRepository);
      },
      act: (cubit) => cubit.loadUsers(nameFilter: 'João', emailFilter: 'joao'),
      verify: (_) {
        verify(() => mockRepository.getUsers(name: 'João', email: 'joao')).called(1);
      },
    );
  });
}
