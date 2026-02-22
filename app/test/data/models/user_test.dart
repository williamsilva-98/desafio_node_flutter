import 'package:app/data/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    test('fromJson fills all fields', () {
      final json = {
        'id': 1,
        'name': 'João Silva',
        'email': 'joao@email.com',
        'created_at': '2025-01-01T12:00:00.000Z',
        'updated_at': '2025-01-01T12:00:00.000Z',
      };
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@email.com');
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('fromJson works without created_at and updated_at', () {
      final json = {
        'id': 2,
        'name': 'Maria',
        'email': 'maria@email.com',
      };
      final user = User.fromJson(json);
      expect(user.id, 2);
      expect(user.name, 'Maria');
      expect(user.email, 'maria@email.com');
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('props includes id, name, email', () {
      const user = User(id: 1, name: 'A', email: 'a@a.com');
      expect(user.props, [1, 'A', 'a@a.com', null, null]);
    });
  });
}
