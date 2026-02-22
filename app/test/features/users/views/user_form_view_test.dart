import 'package:app/core/di/injection.dart';
import 'package:app/data/models/user.dart';
import 'package:app/data/repositories/user_repository.dart';
import 'package:app/features/users/view_models/users_form/user_form_cubit.dart';
import 'package:app/features/users/views/user_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    getIt.reset();
    getIt.registerSingleton<UserRepository>(mockRepository);
    getIt.registerFactory<UserFormCubit>(
      () => UserFormCubit(userRepository: getIt<UserRepository>()),
    );
  });

  testWidgets('displays name, email and register button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => getIt<UserFormCubit>(),
          child: const UserFormView(),
        ),
      ),
    );

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
  });

  testWidgets('when filling and registering calls repository',
      (WidgetTester tester) async {
    when(() => mockRepository.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        )).thenAnswer((_) async => const User(id: 1, name: 'Maria', email: 'maria@email.com'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => getIt<UserFormCubit>(),
          child: const UserFormView(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Maria');
    await tester.enterText(find.byType(TextField).at(1), 'maria@email.com');
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.createUser(
          name: 'Maria',
          email: 'maria@email.com',
        )).called(1);
  });
}
