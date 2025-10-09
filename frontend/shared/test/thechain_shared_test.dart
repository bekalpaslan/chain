import 'package:flutter_test/flutter_test.dart';
import 'package:thechain_shared/thechain_shared.dart';

void main() {
  group('ApiConstants', () {
    test('has correct default base URL', () {
      expect(ApiConstants.defaultBaseUrl, 'http://localhost:8080');
    });

    test('has correct auth endpoints', () {
      expect(ApiConstants.authLogin, '/auth/login');
      expect(ApiConstants.authRegister, '/auth/register');
      expect(ApiConstants.authRefresh, '/auth/refresh');
    });

    test('has correct user endpoints', () {
      expect(ApiConstants.usersMe, '/users/me');
      expect(ApiConstants.usersMeChain, '/users/me/chain');
    });
  });

  group('AppConstants', () {
    test('has correct app name', () {
      expect(AppConstants.appName, 'The Chain');
    });

    test('has correct ticket expiry', () {
      expect(AppConstants.ticketExpiryHours, 24);
    });

    test('has correct max wasted tickets', () {
      expect(AppConstants.maxWastedTickets, 3);
    });
  });

  group('User model', () {
    test('creates user from JSON', () {
      final json = {
        'userId': 'test-id',
        'chainKey': 'SEED00000001',
        'displayName': 'Test User',
        'position': 1,
        'status': 'active',
        'wastedTicketsCount': 0,
        'createdAt': '2025-10-09T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.userId, 'test-id');
      expect(user.chainKey, 'SEED00000001');
      expect(user.displayName, 'Test User');
      expect(user.position, 1);
      expect(user.status, 'active');
      expect(user.wastedTicketsCount, 0);
    });

    test('converts user to JSON', () {
      final user = User(
        userId: 'test-id',
        chainKey: 'SEED00000001',
        displayName: 'Test User',
        position: 1,
        status: 'active',
        wastedTicketsCount: 0,
        createdAt: DateTime.parse('2025-10-09T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['userId'], 'test-id');
      expect(json['chainKey'], 'SEED00000001');
      expect(json['displayName'], 'Test User');
    });
  });

  group('ChainStats model', () {
    test('creates chain stats from JSON', () {
      final json = {
        'totalUsers': 100,
        'activeUsers': 85,
        'removedUsers': 15,
        'totalTickets': 200,
        'activeTickets': 50,
        'usedTickets': 100,
        'expiredTickets': 50,
        'chainLength': 100,
      };

      final stats = ChainStats.fromJson(json);

      expect(stats.totalUsers, 100);
      expect(stats.activeUsers, 85);
      expect(stats.chainLength, 100);
    });
  });
}
