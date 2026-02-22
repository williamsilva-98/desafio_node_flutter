import 'package:app/core/errors/api_exception.dart';
import 'package:app/data/services/user_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late UserApiService service;

  setUp(() {
    mockDio = MockDio();
    service = UserApiService(dio: mockDio);
  });

  group('UserApiService.createUser', () {
    test('returns User when API returns 201', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response<Map<String, dynamic>>(
                requestOptions: RequestOptions(path: '/users'),
                statusCode: 201,
                data: {
                  'id': 1,
                  'name': 'João',
                  'email': 'joao@email.com',
                },
              ));

      final user = await service.createUser(
        name: 'João',
        email: 'joao@email.com',
      );

      expect(user.id, 1);
      expect(user.name, 'João');
      expect(user.email, 'joao@email.com');
    });

    test('throws ApiException when API returns error with message', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/users'),
        response: Response(
          requestOptions: RequestOptions(path: '/users'),
          statusCode: 409,
          data: {'message': 'E-mail já cadastrado'},
        ),
      ));

      expect(
        () => service.createUser(name: 'João', email: 'joao@email.com'),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          'E-mail já cadastrado',
        )),
      );
    });
  });

  group('UserApiService.getUsers', () {
    test('returns list of User when API returns 200', () async {
      when(() => mockDio.get<List<dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response<List<dynamic>>(
                requestOptions: RequestOptions(path: '/users'),
                statusCode: 200,
                data: [
                  {'id': 1, 'name': 'A', 'email': 'a@a.com'},
                ],
              ));

      final users = await service.getUsers();
      expect(users.length, 1);
      expect(users.first.name, 'A');
      expect(users.first.email, 'a@a.com');
    });

    test('returns empty list when data is null', () async {
      when(() => mockDio.get<List<dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response<List<dynamic>>(
                requestOptions: RequestOptions(path: '/users'),
                statusCode: 200,
                data: null,
              ));

      final users = await service.getUsers();
      expect(users, isEmpty);
    });

    test('passes query params when name and email are provided', () async {
      when(() => mockDio.get<List<dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response<List<dynamic>>(
                requestOptions: RequestOptions(path: '/users'),
                statusCode: 200,
                data: [],
              ));

      await service.getUsers(name: 'João', email: 'joao');

      final captured = verify(
        () => mockDio.get<List<dynamic>>(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      expect(captured.first, {'name': 'João', 'email': 'joao'});
    });
  });
}
