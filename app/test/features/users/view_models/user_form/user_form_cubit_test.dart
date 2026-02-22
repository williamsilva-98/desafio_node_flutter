import 'package:app/core/errors/api_exception.dart';
import 'package:app/data/models/user.dart';
import 'package:app/features/users/view_models/users_form/user_form_cubit.dart';
import 'package:app/data/repositories/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
  });

  group('UserFormCubit', () {
    blocTest<UserFormCubit, UserFormState>(
      'emite validationError quando nome vazio',
      build: () => UserFormCubit(userRepository: mockRepository),
      act: (cubit) => cubit.submit(name: '', email: 'a@a.com'),
      expect: () => [
        const UserFormState.validationError('Nome é obrigatório.'),
      ],
    );

    blocTest<UserFormCubit, UserFormState>(
      'emite validationError quando email vazio',
      build: () => UserFormCubit(userRepository: mockRepository),
      act: (cubit) => cubit.submit(name: 'João', email: ''),
      expect: () => [
        const UserFormState.validationError('E-mail é obrigatório.'),
      ],
    );

    blocTest<UserFormCubit, UserFormState>(
      'emite [submitting, success] quando createUser retorna User',
      build: () {
        when(() => mockRepository.createUser(
              name: any(named: 'name'),
              email: any(named: 'email'),
            )).thenAnswer((_) async =>
            const User(id: 1, name: 'João', email: 'joao@email.com'));
        return UserFormCubit(userRepository: mockRepository);
      },
      act: (cubit) => cubit.submit(name: 'João', email: 'joao@email.com'),
      expect: () => [
        const UserFormState.submitting(),
        UserFormState.success(
          const User(id: 1, name: 'João', email: 'joao@email.com'),
        ),
      ],
    );

    blocTest<UserFormCubit, UserFormState>(
      'emite [submitting, apiError] quando createUser lança ApiException',
      build: () {
        when(() => mockRepository.createUser(
              name: any(named: 'name'),
              email: any(named: 'email'),
            )).thenThrow(const ApiException('E-mail já cadastrado', 409));
        return UserFormCubit(userRepository: mockRepository);
      },
      act: (cubit) => cubit.submit(name: 'João', email: 'joao@email.com'),
      expect: () => [
        const UserFormState.submitting(),
        const UserFormState.apiError('E-mail já cadastrado'),
      ],
    );

    blocTest<UserFormCubit, UserFormState>(
      'reset volta ao initial',
      build: () => UserFormCubit(userRepository: mockRepository),
      act: (cubit) => cubit.reset(),
      expect: () => [const UserFormState.initial()],
    );
  });
}
