import 'package:app/core/di/injection.dart';
import 'package:app/data/models/user.dart';
import 'package:app/data/repositories/user_repository.dart';
import 'package:app/features/users/view_models/users_list/user_list_cubit.dart';
import 'package:app/features/users/views/user_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(null);
  });

  setUp(() {
    mockRepository = MockUserRepository();
    getIt.reset();
    getIt.registerSingleton<UserRepository>(mockRepository);
    getIt.registerFactory<UserListCubit>(
      () => UserListCubit(userRepository: getIt<UserRepository>()),
    );
  });

  testWidgets('exibe lista ao carregar usuários', (WidgetTester tester) async {
    when(() => mockRepository.getUsers(
          name: any(named: 'name'),
          email: any(named: 'email'),
        )).thenAnswer((_) async => [
          const User(id: 1, name: 'João Silva', email: 'joao@email.com'),
        ]);

    await tester.pumpWidget(
      MaterialApp(
        home: const UserListView(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('João Silva'), findsOneWidget);
    expect(find.text('joao@email.com'), findsOneWidget);
  });

  testWidgets('exibe mensagem quando lista está vazia',
      (WidgetTester tester) async {
    when(() => mockRepository.getUsers(
          name: any(named: 'name'),
          email: any(named: 'email'),
        )).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: const UserListView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum usuário encontrado'), findsOneWidget);
  });

  testWidgets('botão Buscar aplica filtros', (WidgetTester tester) async {
    when(() => mockRepository.getUsers(
          name: any(named: 'name'),
          email: any(named: 'email'),
        )).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: const UserListView(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'João');
    await tester.enterText(find.byType(TextField).at(1), 'joao@');
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.getUsers(name: 'João', email: 'joao@')).called(1);
  });
}
